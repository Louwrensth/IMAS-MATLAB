<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MEX access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
    xmlns:my="dummy"
    version="2.0">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>

<xsl:param name="DD_GIT_DESCRIBE" as="xs:string" required="yes"/>
<xsl:param name="UAL_GIT_DESCRIBE" as="xs:string" required="yes"/>

<xsl:variable name="version_regex" select="'^([0-9]+)\.([0-9]+)\.([0-9]+)(-.*)?$'"/>
<xsl:variable name="DD_MAJOR" as="xs:int" select="xs:int(replace($DD_GIT_DESCRIBE, $version_regex, '$1'))"/>
<xsl:variable name="DD_MINOR" as="xs:int" select="xs:int(replace($DD_GIT_DESCRIBE, $version_regex, '$2'))"/>
<xsl:variable name="DD_PATCH" as="xs:int" select="xs:int(replace($DD_GIT_DESCRIBE, $version_regex, '$3'))"/>

<xsl:variable name="HLI_MAJOR" as="xs:int" select="xs:int(replace($UAL_GIT_DESCRIBE, $version_regex, '$1'))"/>
<xsl:variable name="HLI_MINOR" as="xs:int" select="xs:int(replace($UAL_GIT_DESCRIBE, $version_regex, '$2'))"/>
<xsl:variable name="HLI_PATCH" as="xs:int" select="xs:int(replace($UAL_GIT_DESCRIBE, $version_regex, '$3'))"/>

<xsl:template match="/IDSs">
    <xsl:result-document href="src/imas_versions.c" method="text">
/*
 * imas_versions.c - lists versions of the Lowlevel access layer, HLI and DD
 *
 *              imas_versions(field_path, plugin_name)
 *
 * This is a MEX file for MATLAB.
 */
#include "imas_mex_utils.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{

    /* Check for one input arguments   */
    if (nrhs != 0) {
        mexErrMsgIdAndTxt("IMAS:imas_versions:nargin", "Zero inputs required.");
    }
    /* Check for one output argument */
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("IMAS:imas_versions:nargout", "One output required.");
    }
    /* create a 1x1 struct matrix for output  */
    int nfields = 5;
    const char *fnames[] = {"al_version", "hli_version", "dd_version",
                            "hli_version_array", "dd_version_array"};
    plhs[0] = mxCreateStructMatrix(1, 1, nfields, fnames);

    mxArray *arr;
    mxInt32 *version_data;
    const mwSize dims[] = {3};

    arr = mxCreateString(getUALVersion());
    mxSetField(plhs[0], 0, "al_version", arr);

    arr = mxCreateString("<xsl:value-of select="$UAL_GIT_DESCRIBE"/>");
    mxSetField(plhs[0], 0, "hli_version", arr);

    arr = mxCreateNumericArray(1, dims, mxINT32_CLASS, mxREAL);
    version_data = mxGetData(arr);
    version_data[0] = <xsl:value-of select="$HLI_MAJOR"/>;
    version_data[1] = <xsl:value-of select="$HLI_MINOR"/>;
    version_data[2] = <xsl:value-of select="$HLI_PATCH"/>;
    mxSetField(plhs[0], 0, "hli_version_array", arr);

    arr = mxCreateString("<xsl:value-of select="$DD_GIT_DESCRIBE"/>");
    mxSetField(plhs[0], 0, "dd_version", arr);

    arr = mxCreateNumericArray(1, dims, mxINT32_CLASS, mxREAL);
    version_data = mxGetData(arr);
    version_data[0] = <xsl:value-of select="$DD_MAJOR"/>;
    version_data[1] = <xsl:value-of select="$DD_MINOR"/>;
    version_data[2] = <xsl:value-of select="$DD_PATCH"/>;
    mxSetField(plhs[0], 0, "dd_version_array", arr);
}
    </xsl:result-document>
</xsl:template>

</xsl:stylesheet>
