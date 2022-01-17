nodes = [
    'T', 'kT', 'dkT',
    'aT', 'kaT', 'dkaT', 'aaT', 'daaT', 'kdaaT', 
    'dkdaaT', 'aaaT', 'daaaT', 'daT', 'kdaT', 'dkdaT', 'saT', 'dsaT',
    'sT', 'ksT', 'dksT', 'asT', 'dasT', 'kdasT', 
    'dkdasT', 'aasT', 'daasT', 'dsT', 'kdsT', 'dkdsT', 'ssT', 'dssT'
]

edges = {
    'kT': 'T',
    'dkT': 'kT',
    'aT': 'T',
    'kaT': 'aT',
    'dkaT': 'kaT',
    'aaT': 'aT',
    'daaT': 'aaT',
    'kdaaT': 'daaT',
    'dkdaaT': 'kdaaT',
    'aaaT': 'aaT',
    'daaaT': 'aaaT',
    'daT': 'aT',
    'kdaT': 'daT',
    'dkdaT': 'kdaT',
    'saT': 'aT',
    'dsaT': 'saT',
    'sT': 'T',
    'ksT': 'sT',
    'dksT': 'ksT',
    'asT': 'sT',
    'dasT': 'asT',
    'kdasT': 'dasT',
    'dkdasT': 'kdasT',
    'aasT': 'asT',
    'daasT': 'aasT',
    'dsT': 'sT',
    'kdsT': 'dsT',
    'dkdsT': 'kdsT',
    'ssT': 'sT',
    'dssT': 'ssT',
}

base = {
    "lives": 10,
    "speed": 1,
    "damage": 1,
    "spawn_num": 1
}

bonus = {
    "T": {},
    "k": { "speed": 1.2 },
    "a": { "damage": 2 },
    "d": { "spawn_num": 2 },
    "s": { "speed": 0.8, "lives": 3 },
}

def get_stats (node):
    stats = base.copy()
    bonuses = { k:1 for k in stats }
    for char in node:
        effects = bonus[char]
        for e in effects:
            bonuses[e] = effects[e] * bonuses[e]

    for s in stats:
        stats[s] *= bonuses[s]
    return stats

def get_enemy (node):
    enemy = get_stats(node)
    enemy['name'] = node
    if node in edges:
        enemy['spawn_on_death'] = edges[node]
    enemy["model_name"] = node + '.glb'
    enemy["thumbnail_name"] = node + '.png'
    return enemy


def main ():
    enemies = []
    for n in nodes:
        enemies += [ get_enemy(n) ]
    
    import json
    raw = json.dumps(enemies, indent=4)
    with open("enemies.json", "w") as f: f.write(raw)

if __name__ == "__main__": main()
