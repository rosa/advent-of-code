# --- Day 4: The Ideal Stocking Stuffer ---

# Your puzzle input is bgvyzdsv.
KEY=bgvyzdsv
COUNTER=1
HASH=`md5 -qs "$KEY$COUNTER"`
while [[ "$HASH" != 00000* ]]; do
    let COUNTER=COUNTER+1
    HASH=`md5 -qs "$KEY$COUNTER"`
done

echo The lowest positive integer for 5 zeroes is $COUNTER

while [[ "$HASH" != 000000* ]]; do
    let COUNTER=COUNTER+1
    HASH=`md5 -qs "$KEY$COUNTER"`
done

echo The lowest positive integer for 6 zeroes is $COUNTER
