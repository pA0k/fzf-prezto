# fzf module for zimfw

This module adds configuration for [fzf](https://github.com/junegunn/fzf) to
the [zimfw](https://github.com/zimfw/zimfw) Zsh configuration
framework.

## Installation

zimfw will load modules found in the `${ZIM_HOME}/modules` directory.

add the blow lines to your `${HOME}/.zimrc` file.

 ```zsh
 # add fzf to :zim:modules
 zstyle ':zim' modules \
               .
               .
               .
               fzf
               
zstyle ':zim:module' fzf 'url' 'pA0k/fzf-zim'
 ```

and the followings:

```zsh
zimfw install

exit (or press Ctrl-D)
```

## zimfw parameters

This module adds the following configuration options to your zimfw installation:

```zsh
# Disable keybindings
# zstyle ':zim:fzf' disable-key-bindings 'yes'

# Disable completion
# zstyle ':zim:fzf' disable-completion 'yes'

# Set height of the fzf results (comment for full screen)
zstyle ':zim:fzf' height '30%'

# Open fzf results in a tmux pane (if using tmux)
zstyle ':zim:fzf' tmux 'yes'

# Set colorscheme
# A list of available colorschemes is available in color.zsh
# To add more color schemes of your own, consult
# https://github.com/junegunn/fzf/wiki/Color-schemes and add values to the
# color.zsh file accordingly
zstyle ':zim:fzf' colorscheme 'Solarized Light'
```

Add the above lines to your `${HOME}/.zimrc` file.

## Colorscheme

The `color.zsh` file currently contains three color schemes:
[Solarized](https://ethanschoonover.com/solarized/) (both dark and light
variants) and [Atom's One Dark](https://atom.io/themes/one-dark-syntax). You
can add more color schemes of your own in this file and activate them by
setting the appropriate `zstyle` in `${HOME}/.zimrc`.
