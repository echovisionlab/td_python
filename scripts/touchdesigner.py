# All the specific implementation details for a project go here.
# If anything changes in the Touchdesigner Patch, you will only need to adjust this script.

trigger = op("lfo1")
player = op("moviefilein1")

def play(filepath: str, layer: int):
    player.par.file = filepath
    trigger.par.reset.pulse()