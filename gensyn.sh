#!/bin/bash

while true; do
  clear
  echo -e "\033[1;36m🌀 Gensyn Node Automation Menu:\033[0m"
  echo "1️⃣  Install all dependencies"
  echo "2️⃣  Start GEN tmux session (Gensyn Node)"
  echo "3️⃣  Start LOC tmux session (Firewall + Tunnel)"
  echo "4️⃣  Run: mv swarm.pem rl-swarm/"
  echo "5️⃣  Check if GEN session is running"
  echo "6️⃣  Exit"
  echo -n "👉 Enter your choice [1-6]: "
  read choice

  case $choice in
    1)
      echo "🔧 Installing dependencies..."
      sudo apt update && sudo apt install -y sudo tmux python3 python3-venv python3-pip curl wget screen git lsof ufw
      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      sudo apt update && sudo apt install -y yarn
      curl -sSL https://raw.githubusercontent.com/ABHIEBA/Gensyn/main/node.sh | bash
      echo "✅ Dependencies installed!"
      read -p "Press Enter to continue..."
      ;;

    2)
      tmux has-session -t GEN 2>/dev/null
      if [ $? == 0 ]; then
        echo "⚠️ GEN session already exists. Attaching..."
      else
        echo "🚀 Creating GEN session and running node..."
        tmux new-session -d -s GEN "bash -c '
          cd \$HOME &&
          rm -rf gensyn-testnet &&
          git clone https://github.com/zunxbt/gensyn-testnet.git &&
          chmod +x gensyn-testnet/gensyn.sh &&
          ./gensyn-testnet/gensyn.sh;
          exec bash
        '"
        echo "✅ GEN session started!"
      fi
      sleep 1
      tmux attach-session -t GEN
      ;;

    3)
      tmux has-session -t LOC 2>/dev/null
      if [ $? == 0 ]; then
        echo "⚠️ LOC session already exists. Attaching..."
      else
        echo "🔐 Starting LOC session..."
        tmux new-session -d -s LOC "bash -c '
          sudo ufw allow 22 &&
          sudo ufw allow 3000/tcp &&
          echo y | sudo ufw enable &&
          wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb &&
          sudo dpkg -i cloudflared-linux-amd64.deb &&
          cloudflared tunnel --url http://localhost:3000;
          exec bash
        '"
        echo "✅ LOC session started!"
      fi
      sleep 1
      tmux attach-session -t LOC
      ;;

    4)
      echo "📂 Running: mv swarm.pem rl-swarm/"
      mv swarm.pem rl-swarm/ 2>/dev/null && echo "✅ swarm.pem moved!" || echo "❌ swarm.pem not found!"
      read -p "Press Enter to continue..."
      ;;

    5)
      tmux has-session -t GEN 2>/dev/null
      if [ $? == 0 ]; then
        echo "✅ GEN session is running."
      else
        echo "❌ GEN session is NOT running."
      fi
      read -p "Press Enter to continue..."
      ;;

    6)
      echo "👋 Exiting... goodbye!"
      exit 0
      ;;

    *)
      echo "❌ Invalid input. Choose 1-6 only."
      sleep 2
      ;;
  esac
done
