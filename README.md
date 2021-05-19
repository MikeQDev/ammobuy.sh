# ammobuy.sh

Quick script for checking Cabela's stock...

Since GMail doesn't allow easy SMS sending anymore, email it to your own GMail that has a forward rule to your cell # (then you'll receive a text notification)

Throw it on a cron schedule like so:

`*/15 * * * * /home/user/ammobuy.sh 9mm >> /home/user/ammobuy.log 2>&1`
