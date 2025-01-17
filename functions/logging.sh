#!/bin/sh

# Функция логирования в файл
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Функция для вычисления и регистрации времени, прошедшего с момента запуска скрипта
log_elapsed_time() {
    CURRENT_TIME=$(date +%s)
    ELAPSED_SECONDS=$((CURRENT_TIME - START_TIME))
    ELAPSED_TIME=$(printf "%02d:%02d:%02d" $((ELAPSED_SECONDS / 3600)) $((ELAPSED_SECONDS % 3600 / 60)) $((ELAPSED_SECONDS % 60)))
    log "Elapsed time: $ELAPSED_TIME"
}