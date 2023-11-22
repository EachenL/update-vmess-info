vmesses=$(./get_vmesses.sh)
echo "$vmesses"
vmesses_for_subconverter=$(echo "$vmesses" | tr '\n' '\|' | sed 's/|$//')
echo $vmesses_for_subconverter
cd /home/shundyning/labnet-sub
git pull
echo "http://127.0.0.1:25500/sub?target=clash&url=${after_echo}"
cleaned_url=$(echo -e "$vmesses_for_subconverter" | sed 's/\x1b\[[0-9;]*m//g')
nohup /home/shundyning/subconverter/subconverter &
wget -O /home/shundyning/labnet-sub/subcriptions/subscriptions "http://127.0.0.1:25500/sub?target=clash&url=${cleaned_url}"
git add .
git commit -m "update"
git push
