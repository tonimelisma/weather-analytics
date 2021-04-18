#!/bin/sh

/usr/local/Cellar/mssql-tools/17.7.1.1/bin/sqlcmd -S 192.168.1.2 -U $USERNAME -P $PASSWORD -W -d weather -i calcdist.sql
