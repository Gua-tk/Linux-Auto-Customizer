#!/usr/bin/env bash
pytorch_name="Pytorch"
pytorch_description="Pytorch is a machine learning library for python"
pytorch_version="Python dependent"
pytorch_tags=("customDesktop")
pytorch_systemcategories=("Network")

pytorch_pipinstallations=("torch --extra-index-url https://download.pytorch.org/whl/cpu" "torchvision --extra-index-url https://download.pytorch.org/whl/cpu" "torchaudio --extra-index-url https://download.pytorch.org/whl/cpu")
pytorch_binariesinstalledpaths=("bin/python3;python-torch" "bin/python3;pytorch")
