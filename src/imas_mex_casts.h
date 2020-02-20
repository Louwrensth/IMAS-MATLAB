
#ifndef IMAS_MEX_CASTS_H

#define IMAS_MEX_CASTS_H

al_status_t castDoubleToInt32(mxArray ** data);

al_status_t castInt32ToDouble(mxArray ** data);

al_status_t castNaNToEmpty(mxArray ** data);

al_status_t castEmptyToNaN(mxArray ** data);

al_status_t castCellToChar(mxArray ** data);

al_status_t castCharToCell(mxArray ** data);

al_status_t castCellToStruct(mxArray ** data);

al_status_t castStructToCell(mxArray ** data);

#endif
