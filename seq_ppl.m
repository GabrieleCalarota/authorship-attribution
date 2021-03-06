function  [ppl, logprobs, N] = seq_ppl(seqs, model, show_result)
% compute the perplexity of a string sequence given NPLM
%
% Zhenhao (Roger) Ge, 2015-08-24

% set up default parameter
if nargin < 3, show_result = 0; end

% find target word index
I = model.targetIdx;

% find vocabulary size (index of <unk>)
V = length(model.vocab);

% find parameters
numemb = size(model.weights{1},2);
numhid1 = size(model.weights{2}, 1);
numwords = numhid1 / numemb;
% numdims = numwords + 1;
len_seqs = length(seqs);

% get augmented sequence with padding in the beginning and end
pad = I-1;
seqs2 = cell(1, len_seqs+numwords);
seqs2(1:pad) = {''};
seqs2(pad+len_seqs+1:end) = {''};
seqs2(pad+1:pad+len_seqs) = seqs;

% find probabilities
candidates = {};
probs = zeros(1, len_seqs);
for i = 1:len_seqs
   phrase = seqs2(i:i+numwords);
   probs(i) = seq_probability(phrase, model, candidates, show_result); 
end

% compoute # of OOVs
rm_sil = 0;
seqs_idx = sent2idx(seqs, model.vocab, rm_sil);
num_unk = sum(seqs_idx{1}==V);

% compute N, log. probs and ppl
N = len_seqs - num_unk;
logprobs = sum(log10(probs));
ppl = 10 ^ (-logprobs/N);

