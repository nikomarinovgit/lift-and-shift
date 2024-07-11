#!/bin/bash

# echo "nm-bucket:EXO6e9a69c5809e487b0df721fe:tCQmWdEHtZZWSKbfupP4Qe69c4pFENfRgE9AiXW8xgY" > /root/.passwd-s3fs
# chmod 600 /root/.passwd-s3fs
# s3fs nm-bucket:/ /home/partimag -o url=https://sos-at-vie-1.exo.io -o  passwd_file=/root/.passwd-s3fs

echo 'root:pptpd' | sudo chpasswd
echo 'user:pptpd' | sudo chpasswd
systemctl start ssh


echo "clonezilla-test:EXOdc65249415796c46532f659d:TcxaGSoeUUcBWWVac4Q68q8J3G5ilbREcBg-Gx22VWM" > /root/.passwd-s3fs
chmod 600 /root/.passwd-s3fs
s3fs clonezilla-test:/ /home/partimag -o url=https://sos-at-vie-1.exo.io -o  passwd_file=/root/.passwd-s3fs

