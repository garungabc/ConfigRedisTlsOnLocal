RERUN=`which reflex`
if [[ "$RERUN" == "" ]]; then
    printf "\e[33mInstalling reflex\n"
    go get -u github.com/cespare/reflex
fi
printf "\e[34mWatcher is running...\e[0m\n"
reflex -c ./reflex.conf