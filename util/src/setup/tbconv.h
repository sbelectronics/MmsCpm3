extern int putchartbl(CHARTABL *chrmod);
extern int putdisktbl(DISKTABL *diskmod);
extern void setmbyt(FLOPDEV *flpentry);
extern int putnode();
extern void tbinitflg(CHARDEV *chrentry, byte *xmodbyt);
extern void tbparity(CHARDEV *chrentry, byte *xmodbyt);
extern void tbstopbit(CHARDEV *chrentry, byte *xmodbyt);
extern void tbwlen(CHARDEV *chrentry, byte *xmodbyt);
extern void tbinhand(CHARDEV *chrentry, byte *xmodbyt);
extern void tbouthand(CHARDEV *chrentry, byte *xmodbyt);
extern void tbbaud(CHARDEV *chrentry, byte *chrtbl);
extern void tbsftpt(CHARDEV *chrentry, byte *chrtbl);
extern void tbdrvcontr(FLOPDEV *flpentry);
extern void tbsteprt(FLOPDEV *flpentry);
extern void tbmedia(FLOPDEV *flpentry);
extern void tbmediaft(FLOPDEV *flpentry);
extern void tbsides(FLOPCHAR *flpchar, byte *modebyt);
extern void tbtrkden(FLOPCHAR *flpchar, byte *modebyt);
extern void tbrecden(FLOPCHAR *flpchar, byte *modebyt);
extern void clearbit(byte *array, ushort bitpos);
extern void setbit(byte *array, ushort bitpos);
