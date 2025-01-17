#!/bin/sh

# Функция для копирования файлов
copy_files() {
    local remote_file=$1
    local local_file=$2
    mkdir -p "$(dirname $local_file)"
    cp -p "$remote_file" "$local_file"
}