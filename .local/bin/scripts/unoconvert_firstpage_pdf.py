import sys
import os
import uno
from com.sun.star.beans import PropertyValue


def convert_first_page(infile, outfile):
    # Connect to the running LibreOffice server (unoserver)
    localContext = uno.getComponentContext()
    resolver = localContext.ServiceManager.createInstanceWithContext(
        "com.sun.star.bridge.UnoUrlResolver", localContext)

    # Adjust port if your unoserver uses a different one (default is often 2002)
    ctx = resolver.resolve("uno:socket,host=localhost,port=2002;urp;StarOffice.ComponentContext")
    smgr = ctx.ServiceManager
    desktop = smgr.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)

    # Convert path to URL
    input_url = "file://" + os.path.abspath(infile)
    output_url = "file://" + os.path.abspath(outfile)

    # Load the document (Hidden)
    load_props = (
        PropertyValue(Name="Hidden", Value=True),
        PropertyValue(Name="ReadOnly", Value=True),
    )
    doc = desktop.loadComponentFromURL(input_url, "_blank", 0, load_props)

    try:
        # Define Filter Options
        # Note: We explicitly force the "1" to be a string here
        filter_data = (
            PropertyValue(Name="PageRange", Value="1"),
            PropertyValue(Name="SelectPdfVersion", Value=0),
        )

        # Determine filter name based on extension (simple detection)
        ext = os.path.splitext(infile)[1].lower()
        if ext in ['.pptx', '.ppt', '.pptm', '.odp']:
            filter_name = "impress_pdf_Export"
        elif ext in ['.xlsx', '.xls', '.csv', '.ods']:
            filter_name = "calc_pdf_Export"
        elif ext in ['.docx', '.doc', '.odt']:
            filter_name = "writer_pdf_Export"

        # Set output properties
        save_props = (
            PropertyValue(Name="FilterName", Value=filter_name),
            PropertyValue(Name="FilterData", Value=uno.Any("[]com.sun.star.beans.PropertyValue", filter_data)),
            PropertyValue(Name="Overwrite", Value=True),
        )

        # Export
        doc.storeToURL(output_url, save_props)
        #print(f"Converted {infile} -> {outfile} (Page 1 only)")

    finally:
        if doc:
            doc.close(True)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 unoconvert_firstpage_pdf.py <input_file> <output_file>")
        sys.exit(1)
    convert_first_page(sys.argv[1], sys.argv[2])
