import os

WIDTH = int(os.environ["WIDTH"])
FRAC = int(os.environ["FRAC"])
B1_COEF = int(os.environ["B1_COEF"])
Y1_INIT = int(os.environ["Y1_INIT"])

def model(n):
    y1, y2 = Y1_INIT, 0
    samples = []
    for _ in range(n):
        y = (B1_COEF * y1 - (1 << FRAC) * y2 + (1 << (FRAC - 1))) >> FRAC
        y = max(-(1 << (WIDTH - 1)), min((1 << (WIDTH - 1)) - 1, y))
        samples.append(y)
        y1, y2 = y, y1
    return samples