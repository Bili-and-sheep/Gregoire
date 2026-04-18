#!/usr/bin/env python3
"""
NetScan - Détection des hôtes actifs et de leurs ports ouverts
Auteur : Arno Teixeira
Commentaire : Petit outil de scan réseau pour apprentissage.
"""

import os
import json
from scapy.all import ARP, Ether, srp, TCP, IP, sr1
import networkx as nx
import matplotlib.pyplot as plt

IP_RANGE = "10.21.1.1/16"
OUTPUT_DIR = "output"
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "results.json")

def scan_hosts(ip_range):
    print("[*] Scan du réseau en cours...")
    # Création du paquet ARP
    arp = ARP(pdst=ip_range)
    ether = Ether(dst="ff:ff:ff:ff:ff:ff")
    packet = ether / arp

    # Envoi du paquet et réception des réponses
    result = srp(packet, timeout=2, verbose=0)[0]

    devices = []
    for sent, received in result:
        devices.append({'ip': received.psrc, 'mac': received.hwsrc, 'open_ports': []})
    return devices

def scan_ports(devices, ports=[80, 443]):
    print("[*] Scan des ports des hôtes...")
    for device in devices:
        for port in ports:
            pkt = IP(dst=device['ip'])/TCP(dport=port, flags="S")
            resp = sr1(pkt, timeout=1, verbose=0)
            if resp and resp.haslayer(TCP):
                if resp.getlayer(TCP).flags == 0x12:  # SYN-ACK reçu
                    device['open_ports'].append(port)
    return devices

def save_results(devices, filename):
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    with open(filename, 'w') as f:
        json.dump(devices, f, indent=4)
    print(f"[+] Résultats sauvegardés dans {filename}")

def draw_network(devices):
    G = nx.Graph()
    G.add_node("Scanner", color="red")

    for dev in devices:
        label = f"{dev['ip']}\n{dev['mac']}"
        if dev['open_ports']:
            label += f"\nPorts: {', '.join(map(str, dev['open_ports']))}"
        G.add_node(label)
        G.add_edge("Scanner", label)

    pos = nx.spring_layout(G, seed=42)
    nx.draw(G, pos, with_labels=True, node_color="lightblue", node_size=2000, font_size=8)
    plt.title("Carte réseau détectée")
    plt.tight_layout()

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    plt.savefig(os.path.join(OUTPUT_DIR, "network.png"), dpi=300)
    plt.close()
    print("[+] Carte réseau enregistrée dans output/network.png")

if __name__ == "__main__":
    devices = scan_hosts(IP_RANGE)
    devices = scan_ports(devices)
    save_results(devices, OUTPUT_FILE)
    draw_network(devices)
    print("[✓] Scan terminé !")
