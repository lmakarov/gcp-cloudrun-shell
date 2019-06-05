#!/bin/sh
echo Hello ${TARGET:=World}

whoami
echo
mount
echo
ls -la /
echo
ls -la /cloudsql/
