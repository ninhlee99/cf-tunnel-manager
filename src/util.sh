#!/usr/bin/env bash
# --- Utility functions ---

log()   { echo -e "\033[1;34m[INFO]\033[0m $1"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $1"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $1" >&2; }

ask_confirm() {
  read -rp "$1 [y/N]: " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}
