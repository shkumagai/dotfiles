#!/bin/bash

bash xdmp-engine-10x "dstat -tamsl"
bash tgt_wrtr "tail -F /var/log/supervisor/target_result_writer_*/*.log"

bash xdmp-engine-20x "dstat -tamsl"
bash seg_wrkr "tail -F /var/log/supervisor/segment_evaluator_worker_*/*.log"

bash xdmp-engine-456 "dstat -tamsl"
bash seg_wrkr_0 "tail -F /var/log/supervisor/segment_evaluator_worker_*/*.log"

bash pixeling-log
