import sys
print('[1] importing MCC module')
import MCC_Hot_Cold_GUI as M
print('[2] creating QApplication')
from PySide6.QtWidgets import QApplication
app = QApplication(sys.argv)
print('[3] primary screen DPI =', app.primaryScreen().logicalDotsPerInch())
print('[4] UI_SCALE =', M.UI_SCALE)
print('[5] constructing window')
win = M.MCCHotColdGUI()
print('[6] window geometry =', win.geometry())
print('[7] showing window')
win.show()
print('[8] entering exec()')
rc = app.exec()
print('[9] exec returned', rc)
