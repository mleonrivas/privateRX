#property library TargetPainter
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define TRAILING_LABEL "RX_TRAILING_LINE"
#define TARGET_LABEL "RX_TARGET_LINE"
#define COVER_LABEL "RX_COVER_LINE"
#define TRAILING_COLOR Yellow
#define TARGET_COLOR Blue
#define COVER_COLOR Red

void renderTargets(double currentTargetPrice, double currentCoverPrice) {
    renderLine(TARGET_LABEL, currentTargetPrice, TARGET_COLOR);
    renderLine(COVER_LABEL, currentCoverPrice, COVER_COLOR);
    long cid = ChartID();
    ChartRedraw(cid);
}

void renderTrailing(double price) {
    renderLine(TRAILING_LABEL, price, TRAILING_COLOR);
    long cid = ChartID();
    ChartRedraw(cid);
}

void removeTargets() {
    removeLine(TARGET_LABEL);
    removeLine(COVER_LABEL);
    removeLine(TRAILING_LABEL);
    long cid = ChartID();
    ChartRedraw(cid);
}

void renderLine(string label, double price, double col) {
    int of = ObjectFind(label);
    long cid = ChartID();
    if(of > -1) {
        ObjectMove(cid, label, 0, 0, price);
    } else {
        ObjectCreate(cid,label, OBJ_HLINE, 0, 0, price);
        ObjectSet(label, 6, col);
        ObjectSet(label, 8, 2);
    }
}

void removeLine(string label) {
    long cid = ChartID();
    int of = ObjectFind(label);
    if(of > -1) {
        ObjectDelete(cid, label);
    }
}
