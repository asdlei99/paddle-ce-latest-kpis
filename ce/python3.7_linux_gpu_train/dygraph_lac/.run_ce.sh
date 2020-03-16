#!/bin/bash
export FLAGS_fraction_of_gpu_memory_to_use=0.02
export FLAGS_eager_delete_tensor_gb=0.0
export FLAGS_fast_eager_deletion_mode=1
export CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7

train() {
    python -m paddle.distributed.launch  --selected_gpus=$1 train.py \
        --train_data ./data/train.tsv \
        --test_data ./data/test.tsv \
        --model_save_dir ./padding_models \
        --validation_steps 1000 \
        --save_steps 10000 \
        --print_steps 1 \
        --batch_size 400 \
        --epoch 1 \
        --traindata_shuffle_buffer 20000 \
        --word_emb_dim 128 \
        --grnn_hidden_dim 128 \
        --bigru_num 2 \
        --base_learning_rate 1e-3 \
        --emb_learning_rate 2 \
        --crf_learning_rate 0.2 \
        --word_dict_path ./conf/word.dic \
        --label_dict_path ./conf/tag.dic \
        --word_rep_dict_path ./conf/q2b.dic \
        --enable_ce false \
        --use_cuda true \
        --cpu_num 1 \
        --use_data_paralle True \
        --enable_ce true
}

train_single() {
    python train.py \
        --train_data ./data/train.tsv \
        --test_data ./data/test.tsv \
        --model_save_dir ./padding_models \
        --validation_steps 1000 \
        --save_steps 10000 \
        --print_steps 200 \
        --batch_size 400 \
        --epoch 1 \
        --traindata_shuffle_buffer 20000 \
        --word_emb_dim 128 \
        --grnn_hidden_dim 128 \
        --bigru_num 2 \
        --base_learning_rate 1e-3 \
        --emb_learning_rate 2 \
        --crf_learning_rate 0.2 \
        --word_dict_path ./conf/word.dic \
        --label_dict_path ./conf/tag.dic \
        --word_rep_dict_path ./conf/q2b.dic \
        --enable_ce true \
        --use_cuda true \
        --cpu_num 1
}

cudaid=0
export CUDA_VISIBLE_DEVICES=$cudaid
train_single $cudaid 1>log_1card
cat log_1card | python _ce.py


cudaid=4,5,6,7
export CUDA_VISIBLE_DEVICES=$cudaid
train $cudaid 1>log_4card
cat log_4card | python _ce.py
