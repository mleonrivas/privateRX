#property library TargetPainter
#property copyright "Scientia Trader QuanT"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define TARGET_LABEL "RX_TARGET_LINE"
#define COVER_LABEL "RX_COVER_LINE"
#define TARGET_COLOR Blue
#define COVER_COLOR Red

void renderTargets(double currentTargetPrice, double currentCoverPrice) {
    renderLine(TARGET_LABEL, currentTargetPrice, TARGET_COLOR);
    renderLine(COVER_LABEL, currentCoverPrice, COVER_COLOR);
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
    ChartRedraw(cid);
}
