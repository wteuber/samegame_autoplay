#!/usr/bin/bash
make -C ./player/
make -C ./solver/brute-force/
chmod -R 644 *
chmod 755 ./*.rb ./*.sh
chmod 755 ./player/bin/*
chmod 755 ./solver/brute-force/bin/*.*
chmod 755 ./solver/evolutionary/*.*
