## Lumen | _Configure Redis Tls on Local with Docker_

Config Redis TLS on local with docker.

## Step By Step

- Run sh file to create certification for Redis TLS: ``` sh setup_local/gen-certs-redis.sh ```
- Setup variables in .env file:
   ```php
    REDIS_DB
    REDIS_HOST
    REDIS_USERNAME
    REDIS_PASSWORD
    REDIS_PORT=6379
   ```
- Update config redis in database.php file
    ```php
    // remove "return" instead by variable "$database_config"
    $database_config = [
    ...
    ];
    
    // add this code block
    if (in_array(env('APP_ENV'), ['local'])) {
        $database_config['redis']['default']['ssl'] = [
            'verify_peer' => false,
            'verify_peer_name' => false
        ];
    }
    return $database_config;
    ```
    > **Note**: 
    > "verify_peer": Determines whether Lumen should verify the Redis server's SSL certificate or not. 
    > "verify_peer_name": Specifies the common name of the SSL certificate that Lumen will use to verify the Redis server.
    
- Testing and enjoy.

---
### Example to testing
In routes/web.php
```php
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Redis;

$router->get('/set-cache', function() {
    $time_now = time();
    Redis::set("key-test", "value-test-" . $time_now, 'EX', 20);
    Cache::put("key-test", "value-test-" . $time_now, 20);
    dd(Cache::get("key-test"), Redis::get("key-test"), $time_now);
});
$router->get('/get-cache', function() {
    dd(Cache::get("key-test"), Redis::get("key-test"));
});
```