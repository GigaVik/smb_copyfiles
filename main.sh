#!/bin/sh

# Подключаем конфигурационные переменные
source ./config.sh

# Подключаем все функции из каталога functions
for func_file in $(find ./functions -type f -name "*.sh"); do
    source "$func_file"
done

# Запись времени запуска скрипта
START_TIME=$(date +%s)

echo "" >> $LOG_FILE
echo "" >> $LOG_FILE
echo "" >> $LOG_FILE
echo "	" >> $LOG_FILE
echo "	Начало работы скрипта	" >> $LOG_FILE
echo "	" >> $LOG_FILE

# Цикл обработки каталогов удаленный/локальный
for i in "${!REMOTE_SHARES[@]}"; do
    REMOTE_SHARE=${REMOTE_SHARES[$i]}
    LOCAL_DIR_BASE=${LOCAL_DIRS[$i]}
    
    DIR_DATE=$(get_dir_date)
    LOCAL_DIR="$LOCAL_DIR_BASE/$DIR_DATE"

    if [ -z "$LOCAL_DIR_BASE" ]; then
        log "Пропуск пустого удаленного общего ресурса."
        continue
    fi

    MOUNT_POINT="/mnt/remoteshare_$i"
    log "Директория $REMOTE_SHARE смонтирована в $MOUNT_POINT"
    mkdir -p $MOUNT_POINT

    mount_remote_share $REMOTE_SHARE $MOUNT_POINT || continue

    START_MONTH_EPOCH=$(get_start_of_month_epoch)
    YESTERDAY_MIDNIGHT_EPOCH=$(get_yesterday_midnight_epoch)
    mkdir -p $LOCAL_DIR

    log "	"
    log "Поиск в $REMOTE_SHARE файлов созданных в период "
    log "с $(date -d "@$START_MONTH_EPOCH" +%Y-%m-%d\ %H:%M:%S) по $(date -d "@$YESTERDAY_MIDNIGHT_EPOCH" +%Y-%m-%d\ %H:%M:%S)"
    log "	"

    COPIED_COUNT=0
    find $MOUNT_POINT -type f | while read REMOTE_FILE; do
        # Пропуск файлов с именем "00000000"
        if echo "$REMOTE_FILE" | grep -q '^/mnt/remoteshare_'$i'/00000000'; then
            if [ "$VERBOSE" = true ]; then
                log "DEBUG: Пропуск файлов $REMOTE_FILE (с именем 00000000)"
            fi
            continue
        fi

        MOD_TIME=$(stat -L -t "$REMOTE_FILE" | awk '{print $14}')
        if [ -z "$MOD_TIME" ]; then
            log "Не удается получить время изменения для файла $REMOTE_FILE"
            continue
        fi

        MOD_TIME_HUMAN=$(date -d "@$MOD_TIME" +%Y-%m-%d\ %H:%M:%S)

        if [ "$MOD_TIME" -ge "$START_MONTH_EPOCH" ] && [ "$MOD_TIME" -le "$YESTERDAY_MIDNIGHT_EPOCH" ]; then
            REL_PATH=$(echo $REMOTE_FILE | sed "s|$MOUNT_POINT||")
            LOCAL_FILE="$LOCAL_DIR$REL_PATH"
            if [ ! -e "$LOCAL_FILE" ]; then
                COPIED_COUNT=$((COPIED_COUNT + 1))
                if [ "$VERBOSE" = true ]; then
                    log "DEBUG: Копирование файла $REMOTE_FILE (изменен $MOD_TIME_HUMAN) в $LOCAL_FILE"
                fi
                mkdir -p "$(dirname $LOCAL_FILE)"
                cp -p "$REMOTE_FILE" "$LOCAL_FILE"
            fi
        fi
    done

    log "Скопировано файлов: $COPIED_COUNT"
    log "Размонтирование удаленной директории $REMOTE_SHARE из $MOUNT_POINT"
    umount $MOUNT_POINT 2>> $LOG_FILE
    log "Синхронизация файлов между $REMOTE_SHARE и $LOCAL_DIR завершена."
done

log_elapsed_time
echo "	Завершение работы скрипта	" >> $LOG_FILE
echo "	" >> $LOG_FILE