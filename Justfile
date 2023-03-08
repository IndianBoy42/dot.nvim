nvim := "nvim"

# This is just here to handle empty `just` invocations
@_default:
    just --list

# Update nvim in YADM
yadm-save message="update nvim config": fix-head
    git pull
    git push 
    cd ~  && yadm add ~/.config/nvim 
    yadm commit -m "{{message}}"

venv-install: 
    sudo apt install python3.9 python3.9-dev python3.9-venv
    python3.9 -m venv ~/.config/nvim/.venv
    ~/.config/nvim/.venv/bin/python3.9 -m pip install pynvim 
    ~/.config/nvim/.venv/bin/python3.9 -m pip install cairosvg pnglatex jupyter_client ipython pillow plotly kaleido
    ~/.config/nvim/.venv/bin/python3.9 -m pip install keyring tornado requests


# Install dependencies # TODO: there are some dependencies not included here
install:
    sudo apt install libjpeg8-dev zlib1g-dev libxtst-dev 
    just venv-install
    {{nvim}} --headless "+Lazy! sync" +qa

stylua:
    #!/usr/bin/env fish
    stylua lua/**.lua
