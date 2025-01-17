#!/bin/sh

# Функция для получения каталога за год и месяц
get_dir_date() {
    if [ "$(date +%d)" = "01" ]; then
        echo "$(date -d "last month" +%Y.%m)"
    else
        echo "$(date +%Y.%m)"
    fi
}

# Функция для вычисления начала месяца
get_start_of_month_epoch() {
    START_MONTH_EPOCH=$(date -d "$(date +%Y-%m-01) 00:00:00" +%s 2>/dev/null)
    if [ -z "$START_MONTH_EPOCH" ]; then
        CURRENT_MONTH=$(date +%m)
        CURRENT_YEAR=$(date +%Y)
        START_MONTH_EPOCH=$(date -m "$CURRENT_MONTH" -d 1 -y "$CURRENT_YEAR" +%s 2>/dev/null)
        if [ -z "$START_MONTH_EPOCH" ]; then
            TODAY_EPOCH=$(date +%s)
            DAY=$(date +%d)
            START_MONTH_EPOCH=$((TODAY_EPOCH - (DAY - 1) * 86400))
        fi
    fi
    echo "$START_MONTH_EPOCH"
}

# Функция для вычисления вчерашней даты (конец вчерашнего дня, 23:59:59)
get_yesterday_midnight_epoch() {
    TODAY_EPOCH=$(date +%s)
    TODAY_START_EPOCH=$(date -d "$(date +%Y-%m-%d) 00:00:00" +%s)
    YESTERDAY_MIDNIGHT_EPOCH=$((TODAY_START_EPOCH - 1))
    echo "$YESTERDAY_MIDNIGHT_EPOCH"
    log "DEBUG: YESTERDAY_MIDNIGHT_EPOCH = $(date -d "@$YESTERDAY_MIDNIGHT_EPOCH" +%Y-%m-%d\ %H:%M:%S)"
}