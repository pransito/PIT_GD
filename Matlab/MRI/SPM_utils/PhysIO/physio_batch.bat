@echo off
title physio batch
matlab -r cd('E:\Charite\PhysIO\PhysIO_scripts')
matlab -r physio_job_batch('E:\Charite\VPPG_Daten\','VPPG*')
pause