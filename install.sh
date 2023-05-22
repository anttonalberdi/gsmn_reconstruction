#Installation in MacOS
# 1) Install the latest version of X11 (https://www.xquartz.org/)
# 2) Install Pathway Tools using the dmg (requires latest version of X11)
# 3) Install m2m (and all dependencies) in a dedicated conda environment

conda create --name m2m python==3.7.5
conda activate m2m
pip install Metage2Metabo
conda install -c anaconda networkx
conda install -c conda-forge ete3
pip install bubbletools
conda install -c conda-forge clyngor
pip install clyngor-with-clingo
conda install -c bioconda menetools
pip install miscoto
pip install powergrasp
conda install -c anaconda libxcb

#Install and preparen ncbi blast
conda install -c bioconda blast
echo "[ncbi]\nData=/usr/bin/data" > ~/.ncbirc

#Add pathway-tools launcher to PATH
cp ~/pathway-tools/pathway-tools /usr/local/bin

#Test m2m
conda activate m2m
m2m -h
