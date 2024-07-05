## Golang | _Configure Redis Tls on Local with Docker_

Config Redis TLS on local with docker.

## Step By Step

- Run sh file to create certification keys for Redis TLS: ``` sh setup_local/gen-certs-redis.sh ```
- Setup variables for your enviroment
   ```php
    REDIS_DB
    REDIS_HOST
    REDIS_USERNAME
    REDIS_PASSWORD
    REDIS_PORT=6379
   ```
- Create file redis.go to handle connection to redis server
    ```
    package gredis

    import (
    	"appota-ewallet-voucher-service-v2/config"
    	"crypto/tls"
    	"fmt"
    	"time"
    
    	"github.com/gomodule/redigo/redis"
    )
    
    type RConfig struct {
    	MaxIdle     int
    	MaxActive   int
    	Wait        bool
    	IdleTimeout time.Duration
    }
    
    // NewPool func
    func NewPool() *redis.Pool {
    	rCnf := RConfig{
    		MaxIdle:     20,
    		MaxActive:   5000,
    		Wait:        true,
    		IdleTimeout: 1 * time.Hour,
    	}
    
    	return NewPoolWithConfig(rCnf)
    }
    
    func NewPoolWithConfig(rCnf RConfig) *redis.Pool {
    	conf := config.GetConfig()
    
    	insecureSkipVerify := false
    	if conf.Server.GinMode == "debug" {
    		insecureSkipVerify = true
    	}
    	tlsConfig := &tls.Config{
    		InsecureSkipVerify: insecureSkipVerify, // Enable for testing or self-signed certificates
    	}
    
    	return &redis.Pool{
    		MaxIdle: rCnf.MaxIdle, // Maximum number of idle connections in the pool.
    		MaxActive:   rCnf.MaxActive, // max number of connections
    		Wait:        rCnf.Wait,
    		IdleTimeout: rCnf.IdleTimeout,
    		// Dial is an application supplied function for creating and
    		// configuring a connection.
    		Dial: func() (redis.Conn, error) {
    			c, err := redis.Dial(
    				"tcp",
    				conf.Redis.Host+":"+conf.Redis.Port,
    				redis.DialUseTLS(true),
    				redis.DialPassword(conf.Redis.Pass),
    				redis.DialUsername(conf.Redis.Username),
    				redis.DialDatabase(conf.Redis.Database),
    				redis.DialTLSConfig(tlsConfig),
    			)
    			if err != nil {
    				fmt.Println("Error connecting to Redis:", err.Error())
    				panic(err.Error())
    			}
    
    			return c, err
    		},
    	}
    }

    ```
    > **Note**: 
    > "verify_peer": Determines whether Lumen should verify the Redis server's SSL certificate or not. 
    > "verify_peer_name": Specifies the common name of the SSL certificate that Lumen will use to verify the Redis server.
    
- Testing and enjoy.

---
### Example to testing

1. Create Repository to handle Set-Get redis data

    ```
    package repository
    
    import (
    	"github.com/gomodule/redigo/redis"
    )
    
    var (
    	checkinifo   = "gamicheckininfo"
    	userinfo     = "gamiuserinfo"
    	userekycinfo = "gamiekycuserinfo"
    	userbankinfo = "gamiuserbankinfo"
    )
    
    type redisCacheRepository struct {
    	pool *redis.Pool
    }
    
    // NewRedisCacheRepository func
    func NewRedisCacheRepository(pool *redis.Pool) CacheRepository {
    	return &redisCacheRepository{pool}
    }
    
    func (r *redisCacheRepository) SetByKey(key string, value interface{}, ttl int) error {
    	conn := r.pool.Get()
    	defer conn.Close()
    
    	// SET object
    	_, err := conn.Do("SET", key, value)
    	if err != nil {
    		return err
    	}
    
    	_, err = conn.Do("EXPIRE", key, ttl)
    	if err != nil {
    		return err
    	}
    
    	return nil
    }
    
    func (r *redisCacheRepository) DeleteByKey(key string) error {
    	conn := r.pool.Get()
    	defer conn.Close()
    
    	_, err := conn.Do("DEL", key)
    	if err != nil {
    		return err
    	}
    
    	return nil
    }
    
    func (r *redisCacheRepository) GetByKey(cacheKey string) (interface{}, error) {
    	conn := r.pool.Get()
    	defer conn.Close()
    
    	cache_val, err_get_cache := redis.String(conn.Do("GET", cacheKey))
    	if err_get_cache != nil {
    		return "", err_get_cache
    	}
    
    	return cache_val, nil
    }
    ```
2. Create handles to testing
    ```
    func (h *voucherHandler) SetDataRedis(c *gin.Context) {
    	ttl := 20
    	time_now := time.Now().Format("2006-01-02 15:04:05")
    	err := h.cacheRepo.SetByKey("redis-here", "value - "+time_now, ttl)
    	if err != nil {
    		log.Println("Error setting redis:", err.Error(), "redis-here", time_now, ttl)
    	}
    
    	val, err := h.cacheRepo.GetByKey("redis-here")
    	if err != nil {
    		log.Println("Error getting redis:", err.Error())
    	}
    
    	resp := map[string]interface{}{
    		"key":   "redis-here",
    		"value": val,
    		"ttl":   ttl,
    	}
    	c.JSON(http.StatusOK, resp)
    }
    
    func (h *voucherHandler) GetDataRedis(c *gin.Context) {
    	val, err := h.cacheRepo.GetByKey("redis-here")
    	if err != nil {
    		log.Println("Error getting redis:", err.Error())
    	}
    
    	resp := map[string]interface{}{
    		"key":   "redis-here",
    		"value": val,
    	}
    	c.JSON(http.StatusOK, resp)
    }
    ```