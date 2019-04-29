
#ifndef IMAS_MEX_CASTS_H

#define IMAS_MEX_CASTS_H

int castDoubleToInt32(mxArray ** data);

int castInt32ToDouble(mxArray ** data);

int castNaNToEmpty(mxArray ** data);

int castEmptyToNaN(mxArray ** data);

int castCellToChar(mxArray ** data);

int castCharToCell(mxArray ** data);

int castCellToStruct(mxArray ** data);

int castStructToCell(mxArray ** data);

#endif
