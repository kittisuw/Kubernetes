## 🧰 Install kubectx, kubens, and fzf with Oh-My-Zsh, Powerlevel10k

> ✅ This setup is tested and compatible with the following OS versions:
>
> | OS Version   | Compatibility     |
> | ------------ | ----------------- |
> | Ubuntu 20.04 | ✅ Fully Supported |
> | Ubuntu 22.04 | ✅ Fully Supported |
> | Ubuntu 24.04 | ✅ Fully Supported |
> | Ubuntu 24.04 | ✅ Fully Supported |
> | macOS (Intel/ARM)| ✅ Fully Supported (Homebrew recommended) |
>
> All tools used here (kubectx, kubens, fzf, oh-my-zsh, and kube-ps1) work seamlessly on these platforms without modification.

### 1. Install kubectx, kubens, and fzf

```bash
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install fzf
sudo apt install fzf -y
```

---

### 2. Set up Aliases in Shell Config

#### For Zsh:

Open `.zshrc`:

```bash
vi ~/.zshrc
```

Add:

```zsh
# kubectx and kubens shortcut aliases
alias ktx='kubectx'
alias kns='kubens'
alias k='kubectl'
```

#### For Bash:

Open `.bashrc`:

```bash
vi ~/.bashrc
```

Add:

```bash
# kubectx and kubens shortcut aliases
alias ktx='kubectx'
alias kns='kubens'
alias k='kubectl'
```

---

### 3. Enable Auto-completion for kubectx and kubens

#### For Zsh:

```zsh
# kubectx/kubens completion for zsh
source <(kubectx completion zsh)
source <(kubens completion zsh)
```

#### For Bash:

```bash
# kubectx/kubens completion for bash
source <(kubectx completion bash)
source <(kubens completion bash)
```

---

### 4. Install fzf with full feature support

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

Select `yes` for all prompts to enable key-bindings and completion.

---

### 5. Add fzf-based ktx/kns Functions

#### For Zsh (`~/.zshrc`):

```zsh
# Fuzzy kubectx with fzf
function ktx() {
  local ctx
  ctx=$(kubectx | fzf --prompt="K8s Context> " --height=40%) && kubectx "$ctx"
}

# Fuzzy kubens with fzf
function kns() {
  local ns
  ns=$(kubens | fzf --prompt="Namespace> " --height=40%) && kubens "$ns"
}
```

#### For Bash (`~/.bashrc`):

```bash
# Fuzzy kubectx with fzf
ktx() {
  local ctx
  ctx=$(kubectx | fzf --prompt="K8s Context> " --height=40%) && kubectx "$ctx"
}

# Fuzzy kubens with fzf
kns() {
  local ns
  ns=$(kubens | fzf --prompt="Namespace> " --height=40%) && kubens "$ns"
}
```

---

### 6. Reload the Shell

#### Zsh:

```bash
source ~/.zshrc
```

#### Bash:

```bash
source ~/.bashrc
```

---

### 7. Test the Shortcuts

* Run `ktx` to interactively switch Kubernetes contexts
* Run `kns` to interactively switch namespaces

#### You can test with the following steps:

```bash
# Check if ktx lists contexts properly
ktx
# Select a context and confirm it has switched
kubectl config current-context

# Check if kns lists namespaces properly
kns
# Confirm active namespace by running:
kubectl config view --minify | grep namespace
```

---

### (Optional) Enhance Prompt with Powerlevel10k and kube-ps1

You can combine `Powerlevel10k` with `kube-ps1` to create a beautiful and informative Zsh prompt that includes the current Kubernetes context and namespace.

#### 0. Install Powerlevel10k (Zsh only)

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
```

Then in `~/.zshrc`, set:

```zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
```

Run:

```bash
source ~/.zshrc
p10k configure  # follow the wizard to customize
```

You can still use kube-ps1 together with Powerlevel10k, or rely on Powerlevel10k's built-in support for Kubernetes.

You can use the `kube-ps1` prompt helper to display the current Kubernetes context and namespace in your shell prompt.

#### 1. Install kube-ps1

```bash
git clone https://github.com/jonmosco/kube-ps1.git ~/.kube-ps1
```

#### 2. Add the following to your shell config:

##### For Zsh (`~/.zshrc`):

```zsh
source ~/.kube-ps1/kube-ps1.sh
PROMPT='$(kube_ps1) '$PROMPT
```

##### For Bash (`~/.bashrc`):

```bash
source ~/.kube-ps1/kube-ps1.sh
PS1="\[\e[33m\]\$(kube_ps1) \[\e[0m\]$PS1"
```

#### 3. Reload your shell

```bash
source ~/.zshrc   # or source ~/.bashrc
```

You should now see something like this in your prompt:

```bash
(user@host:default) ➜
```

This shows the current context and namespace, making it easier to avoid mistakes across environments!

---

### 8. (Optional) Install k9s - Terminal UI for Kubernetes

`k9s` is a powerful terminal-based UI to manage Kubernetes clusters more interactively.

#### Install k9s (Latest Binary Method):

```bash
curl -sSLo k9s.tar.gz https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
mkdir -p ~/.local/bin && tar -xzf k9s.tar.gz -C ~/.local/bin
chmod +x ~/.local/bin/k9s
```

#### Add to PATH:

##### For Bash:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

##### For Zsh:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### Or Install via Homebrew (on macOS/Linux):

```bash
brew install k9s
```

Then simply run:

```bash
k9s
```

`k9s` is a powerful terminal-based UI to manage Kubernetes clusters more interactively.

#### Install k9s (Latest Binary Method):

```bash
curl -sSLo k9s.tar.gz https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
mkdir -p ~/.local/bin && tar -xzf k9s.tar.gz -C ~/.local/bin
chmod +x ~/.local/bin/k9s
```

Add to your PATH if not already:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc
```

#### Or Install via Homebrew (on macOS/Linux):

```bash
brew install k9s
```

Then simply run:

```bash
k9s
```

---

### 🔗 Reference Links

* kubectx & kubens: [https://github.com/ahmetb/kubectx](https://github.com/ahmetb/kubectx)
* fzf: [https://github.com/junegunn/fzf](https://github.com/junegunn/fzf)
* kube-ps1: [https://github.com/jonmosco/kube-ps1](https://github.com/jonmosco/kube-ps1)
