#!/bin/sh

# Функция для монтирования удаленной директории
mount_remote_share() {
    local remote_share=$1
    local mount_point=$2
    mount -t cifs $remote_share $mount_point -o username=$USER,password=9315,domain=NPGES,iocharset=utf8,vers=1.0,rw,nolock 2>> $LOG_FILE
    return $?
}