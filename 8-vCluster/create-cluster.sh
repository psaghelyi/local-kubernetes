#
# installation:
# curl -s -L "https://github.com/loft-sh/vcluster/releases/latest" | sed -nE 's!.*"([^"]*vcluster-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o vcluster && chmod +x vcluster;
# sudo mv vcluster /usr/local/bin;

# create
vcluster create vcluster-1 -n host-namespace-1

vcluster create vcluster-1 -n host-namespace-1 --expose 

# use
vcluster connect vcluster-1 -n host-namespace-1
export KUBECONFIG=./kubeconfig.yaml

# destroy
vcluster delete vcluster-1 -n host-namespace-1 --delete-namespace



