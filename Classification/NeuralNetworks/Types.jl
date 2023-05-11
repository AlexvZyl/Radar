@enum LayerType begin 
    StdConv
    TemporalConv
    Meanpool
    Maxpool
end

Base.@kwdef mutable struct Layer
    stride = (0,0,0)
    kernel = (0,0,0)
    input_size = (0,0,0)
    output_size = (0,0,0)
    padding = (0,0,0)
    kernel_count = 0
    temporal_stride_frames = 0
    temporal_kernel_frames = 0
    temporal_frame_size = 0
    temporal_frame_count = 0
    temporal_frames_count_out = 0
    type = TemporalConv
    dilation = 1
    channels = 1
end

Base.@kwdef mutable struct TrainingResults
    train_acc = 0
    train_loss = 0
    test_acc = 0
    test_loss = 0
    epoch = 0
end

Base.@kwdef mutable struct TrainingState
    current::TrainingResults = TrainingResults()
    optimal::TrainingResults = TrainingResults()
    max_train::TrainingResults = TrainingResults()
    max_test::TrainingResults = TrainingResults()
    timeout = 100
end

@enum ChainType begin 
    LeNet5
    LeNet5Temporal
    AlexNet
end

Base.@kwdef mutable struct Args
    η = 3e-4             ## learning rate
    λ = 0                ## L2 regularizer param, implemented as weight decay
    batchsize = 128      ## batch size
    epochs = 10          ## number of epochs
    seed = 0             ## set seed > 0 for reproducibility
    use_cuda = true      ## if true use cuda (if available)
    infotime = 1 	     ## report every `infotime` epochs
    checktime = 5        ## Save the model every `checktime` epochs. Set to 0 for no checkpoints.
    tblogger = true      ## log training with tensorboard
    split = nothing      ## Train/test split
    frames_folder = "10-Frames"   ## The folder containing the frames to use.
    model::ChainType = AlexNet
    persons::Int = 2
    save_path_parent = "Runs"
    timeout = 100
    dropout = 0.5
    tree = false
end
