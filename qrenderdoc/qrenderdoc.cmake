set(MODULE_NAME QRenderDoc)

# TARGET = qrenderdoc
# TEMPLATE = app

# include path for core renderdoc API
set(INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay)

# Allow includes relative to the root
list(APPEND INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR})

# And relative to 3rdparty
list(APPEND INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR}/3rdparty)

# For Scintilla source builds - we unfortunately are not able to scope these to only
# those source files
list(APPEND INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/include/qt)
list(APPEND INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/include)

# Disable conversions to/from const char * in QString
set(DEFINES 
    QT_NO_CAST_FROM_ASCII QT_NO_CAST_TO_ASCII
    QT_NO_DEPRECATED_WARNINGS
    RDCLOG_PROJECT="QRDOC"
)

set(QMAKE_CXXFLAGS)

# Different output folders per platform
if(WIN32)

    set(RC_INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay)
    set(RC_FILE Resources/qrenderdoc.rc)

	# # generate pdb files even in release
	# QMAKE_LFLAGS_RELEASE+=/MAP
	# QMAKE_CFLAGS_RELEASE /Zi
	# QMAKE_LFLAGS_RELEASE +=/debug /opt:ref

	# !contains(QMAKE_TARGET.arch, x86_64) {
	# 	Debug:DESTDIR =  ${CMAKE_CURRENT_LIST_DIR}/../Win32/Development
	# 	Release:DESTDIR =  ${CMAKE_CURRENT_LIST_DIR}/../Win32/Release
	# } else {
	# 	Debug:DESTDIR =  ${CMAKE_CURRENT_LIST_DIR}/../x64/Development
	# 	Release:DESTDIR =  ${CMAKE_CURRENT_LIST_DIR}/../x64/Release
	# }

	# # Run SWIG here, since normally we run it from VS
	# swig.name = SWIG ${QMAKE_FILE_IN}
	# swig.input = SWIGSOURCES
	# swig.output = ${QMAKE_FILE_BASE}_python.cxx
	# swig.commands =  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/swig/swig.exe -v -Wextra -Werror -O -interface ${QMAKE_FILE_BASE} -c++ -python -modern -modernargs -enumclass -fastunpack -py3 -builtin -I ${CMAKE_CURRENT_LIST_DIR} -I ${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay -outdir . -o ${QMAKE_FILE_BASE}_python.cxx ${QMAKE_FILE_IN}
	# swig.CONFIG target_predeps
	# swig.variable_out = GENERATED_SOURCES
	# silent:swig.commands = @echo SWIG ${QMAKE_FILE_IN} && $$swig.commands
	# QMAKE_EXTRA_COMPILERS swig

    # #renderdoc_python.cxx
    # set(swig_output ${CMAKE_CURRENT_BINARY_DIR}/generated)
    # set(SwigInterfaces "${CMAKE_SOURCE_DIR}/*.i")
    # set(SwigHeaders "Code/pyrenderdoc/*.h")
    # set(QRDHeaders "${CMAKE_SOURCE_DIR}/../Interface/*.h")
    # set(CoreReplayHeaders "${CMAKE_SOURCE_DIR}/renderdoc/api/replay/*.h")

    # set(SWIG_FILE_NAME renderdoc)
    # set(swig_inputs -I${SwigInterfaces} -I${SwigHeaders} -I${QRDHeaders} -I${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay)
    # set(swig_inputs -I${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay)
    # set(swig_cmd ${CMAKE_CURRENT_LIST_DIR}/3rdparty/swig/swig.exe -v -Wextra -Werror -O -interface ${SWIG_FILE_NAME} -c++ -python -modern -modernargs -enumclass -fastunpack -py3 -builtin ${swig_inputs} -outdir ${swig_output} -o ${swig_output}/${SWIG_FILE_NAME}_python.cxx ${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/${SWIG_FILE_NAME}.i)
    # message("swig_cmd:${swig_cmd}")
    # add_custom_command(
    #     #TARGET swig_${SWIG_FILE_NAME}
    #     OUTPUT ${swig_output}/${SWIG_FILE_NAME}_python.cxx
    #     COMMAND ${swig_cmd}
    #     DEPENDS ${SwigInterfaces} ${SwigHeaders} ${QRDHeaders} ${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/${SWIG_FILE_NAME}.i
    #     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    #     COMMENT "Compiling SWIG renderdoc:${swig_output}"
    #     VERBATIM
    # )
    # list(APPEND SWIGSOURCES swig_${SWIG_FILE_NAME})
    # # add_custom_target(
    # #     swig_${SWIG_FILE_NAME}
    # #     #DEPENDS ${swig_output}
    # # )
    # # my_set_target_folder(swig_${SWIG_FILE_NAME} "UI")

    # set(SWIG_FILE_NAME qrenderdoc)
    # #set(swig_inputs -I${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay)
    # set(swig_inputs -I${SwigInterfaces} -I${SwigHeaders} -I${QRDHeaders} -I${CMAKE_CURRENT_LIST_DIR} -I${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay)
    # set(swig_cmd ${CMAKE_CURRENT_LIST_DIR}/3rdparty/swig/swig.exe -v -Wextra -Werror -O -interface ${SWIG_FILE_NAME} -c++ -python -modern -modernargs -enumclass -fastunpack -py3 -builtin ${swig_inputs} -outdir ${swig_output} -o ${swig_output}/${SWIG_FILE_NAME}_python.cxx ${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/${SWIG_FILE_NAME}.i)
    # message("swig_cmd:${swig_cmd}")
    # add_custom_command(
    #     #TARGET swig_${SWIG_FILE_NAME}
    #     OUTPUT ${swig_output}/${SWIG_FILE_NAME}_python.cxx
    #     COMMAND ${swig_cmd}
    #     DEPENDS ${SwigInterfaces} ${SwigHeaders} ${QRDHeaders} ${CMAKE_CURRENT_LIST_DIR}/Code/pyrenderdoc/${SWIG_FILE_NAME}.i
    #     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    #     COMMENT "Compiling SWIG qrenderdoc:${swig_output}"
    #     VERBATIM
    # )
    # list(APPEND SWIGSOURCES swig_${SWIG_FILE_NAME})
	list(APPEND LIBS _renderdoc _qrenderdoc)
    
    if(CMAKE_CL_64)
        SET(QT_LIB_PATH ${CMAKE_CURRENT_LIST_DIR}/3rdparty/Qt/x64)
    else()
        SET(QT_LIB_PATH ${CMAKE_CURRENT_LIST_DIR}/3rdparty/Qt/Win32)
    endif()
    set(QtBinDir ${QT_LIB_PATH}/bin)
    set(QtIncludeDir ${CMAKE_CURRENT_LIST_DIR}/3rdparty/Qt/include)
    include_directories(${CMAKE_CURRENT_LIST_DIR}/3rdparty/Qt/include)
    include_directories(${CMAKE_CURRENT_LIST_DIR}/3rdparty/Qt/include/QtCore)
    include_directories(${CMAKE_CURRENT_LIST_DIR}/3rdparty/Qt/include/QtGui)
    include_directories(${CMAKE_CURRENT_LIST_DIR}/3rdparty/Qt/include/QtNetwork)
    include_directories(${CMAKE_CURRENT_LIST_DIR}/3rdparty/Qt/include/QtSvg)
    include_directories(${CMAKE_CURRENT_LIST_DIR}/3rdparty/Qt/include/QtWidgets)

    #生成 qt UIC(将 Qt Designer 中创建的 UI 文件（.ui 文件）编译为 C++ 代码)
	file(GLOB_RECURSE qt_ui_list ${CMAKE_CURRENT_LIST_DIR}/*.ui)
    if(CMAKE_CL_64)
        set(qt_uic_output ${CMAKE_CURRENT_BINARY_DIR}/x64/generated)
    else()
        set(qt_uic_output ${CMAKE_CURRENT_BINARY_DIR}/x86/generated)
    endif()
    list(APPEND INCLUDEPATH ${qt_uic_output})
    foreach(qt_ui ${qt_ui_list})
        get_file_name(Filename ${qt_ui})
        set(ouput_file ${qt_uic_output}/ui_${Filename}.h)
        if(NOT EXISTS ${ouput_file})
            add_custom_command(
                #TARGET swig_${SWIG_FILE_NAME}
                OUTPUT ${ouput_file}
                COMMAND "${QtBinDir}/uic.exe" "${qt_ui}" -o "${ouput_file}"
                DEPENDS ${Filename}
                WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                #COMMENT "QT5 UIC ${Filename}.ui"
                VERBATIM
            )
        endif()
        list(APPEND SOURCES ${ouput_file})
    endforeach()

    #生成 qt moc(生成元对象代码)
    set(qt_moc_list
        ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/include/qt/ScintillaDocument.h
        ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/include/qt/ScintillaEdit.h
        ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/include/qt/ScintillaEditBase.h
        ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/qt/ScintillaEditBase/ScintillaQt.h
    )
	file(GLOB_RECURSE tmp_list ${CMAKE_CURRENT_LIST_DIR}/3rdparty/toolwindowmanager/*.h)
    list(APPEND qt_moc_list ${tmp_list})
	file(GLOB_RECURSE tmp_list ${CMAKE_CURRENT_LIST_DIR}/Code/*.h)
    list(APPEND qt_moc_list ${tmp_list})
	file(GLOB_RECURSE tmp_list ${CMAKE_CURRENT_LIST_DIR}/Styles/*.h)
    list(APPEND qt_moc_list ${tmp_list})
	file(GLOB_RECURSE tmp_list ${CMAKE_CURRENT_LIST_DIR}/Widgets/*.h)
    list(APPEND qt_moc_list ${tmp_list})
	file(GLOB_RECURSE tmp_list ${CMAKE_CURRENT_LIST_DIR}/Windows/*.h)
    list(APPEND qt_moc_list ${tmp_list})
    foreach(qt_ui ${qt_moc_list})
        if(${qt_ui} MATCHES "3rdparty/qt/")
            continue()
        endif()
        file(STRINGS ${qt_ui} _MOC_KEYWORDS REGEX "Q_OBJECT")
        if(_MOC_KEYWORDS)
            get_file_name(Filename ${qt_ui})
            set(ouput_file ${qt_uic_output}/moc_${Filename}.cpp)
            if(NOT EXISTS ${ouput_file})
                add_custom_command(
                    #TARGET swig_${SWIG_FILE_NAME}
                    OUTPUT ${ouput_file}
                    COMMAND "${QtBinDir}/moc.exe" -DUNICODE -DWIN32 -DWIN64 -D_WIN32 -D_WIN64 -DRENDERDOC_PLATFORM_WIN32 -DSCINTILLA_QT=1 -DSCI_LEXER=1 -DQT_NO_DEBUG -DQT_WIDGETS_LIB -DQT_GUI_LIB -DQT_CORE_LIB -D_MSC_VER=1900 -I"${CMAKE_CURRENT_LIST_DIR}" -I"${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay" -I"${QtIncludeDir}" -I"${QtIncludeDir}/QtWidgets" -I"${QtIncludeDir}/QtGui" -I"${QtIncludeDir}/QtCore" "${qt_ui}" -o "${ouput_file}"
                    DEPENDS ${Filename}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                    #COMMENT "QT5 moc ${Filename}.h"
                    VERBATIM
                )
            endif()
            list(APPEND SOURCES ${ouput_file})
        endif()
    endforeach()
    #qt qrc
    set(qt_qrc_list
        ${CMAKE_CURRENT_LIST_DIR}/Resources/qtconf.qrc
        ${CMAKE_CURRENT_LIST_DIR}/Resources/resources.qrc
    )
    set(qt_qrc_type_list
        qtconf
        resources
    )
    foreach(i RANGE 0 1)
        list(GET qt_qrc_list ${i} qt_ui)
        list(GET qt_qrc_type_list ${i} qrc_type)

        get_file_name(Filename ${qt_ui})
        set(ouput_file ${qt_uic_output}/qrc_${Filename}.cpp)
        if(NOT EXISTS ${ouput_file})
            add_custom_command(
                #TARGET swig_${SWIG_FILE_NAME}
                OUTPUT ${ouput_file}
                COMMAND "${QtBinDir}/rcc.exe" -name ${qrc_type} Resources/${Filename}.qrc -o "${ouput_file}"
                DEPENDS ${Filename}
                WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                COMMENT "QT5 qrc ${qrc_type} ${Filename}"
                VERBATIM
            )
        endif()
        list(APPEND SOURCES ${ouput_file})
    endforeach()


	# add qrc file with qt.conf
	list(APPEND RESOURCES Resources/qtconf.qrc)


	# Include and link against python
	list(APPEND INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR}/3rdparty/python/include)

	# # Include and link against PySide2
	# exists(  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/PySide2/pyside.h ) {
	# 	DEFINES PYSIDE2_ENABLED=1
	# 	INCLUDEPATH  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/shiboken2
	# 	INCLUDEPATH  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/PySide2
	# 	INCLUDEPATH  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/PySide2/QtCore
	# 	INCLUDEPATH  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/PySide2/QtGui
	# 	INCLUDEPATH  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/PySide2/QtWidgets
	# 	!contains(QMAKE_TARGET.arch, x86_64) {
	# 		LIBS  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/Win32/shiboken2.lib
	# 	} else {
	# 		LIBS  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/x64/shiboken2.lib
	# 	}
	# }

    if(CMAKE_CL_64)
        list(APPEND LIBS ${CMAKE_CURRENT_LIST_DIR}/3rdparty/python/x64/python36.lib)
    else()
        list(APPEND LIBS ${CMAKE_CURRENT_LIST_DIR}/3rdparty/python/Win32/python36.lib)
    endif()
    # Include and link against PySide2
    # https://renderdoc.org/qrenderdoc_3rdparty.zip
    if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/PySide2/pyside.h)
        message("pyside2 include found")
        list(APPEND DEFINES PYSIDE2_ENABLED=1)
        list(APPEND INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/shiboken2)
        list(APPEND INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/PySide2)
        list(APPEND INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/PySide2/QtCore)
        list(APPEND INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/PySide2/QtGui)
        list(APPEND INCLUDEPATH ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/PySide2/QtWidgets)
        
        if(CMAKE_CL_64)
            list(APPEND LIBS ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/x64/shiboken2.lib)
            file(COPY ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/x64/shiboken2.dll DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG})
            file(COPY ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/x64/PySide2 DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG})
        else()
            list(APPEND LIBS ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/Win32/shiboken2.lib)
            file(COPY ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/Win32/shiboken2.dll DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG})
            file(COPY ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/Win32/PySide2 DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG})
        ENDIF()
    else()
        message("pyside2 include not found")
    endif()

	list(APPEND LIBS user32.lib)

	# Link against the core library
	list(APPEND LIBS renderdoc)

	# Link against the version library
	list(APPEND LIBS rdoc_version)

	#QMAKE_CXXFLAGS_WARN_ON -= -w34100 
	list(APPEND DEFINES RENDERDOC_PLATFORM_WIN32)

else()
    # HA HA good joke, QT_NO_DEPRECATED_WARNINGS only covers SOME warnings, not all
    list(APPEND QMAKE_CXXFLAGS -Wno-deprecated-declarations)
	# isEmpty(CMAKE_DIR) {
	# 	error("When run from outside CMake, please set the Build Environment Variable CMAKE_DIR to point to your CMake build root. In Qt Creator add CMAKE_DIR=/path/to/renderdoc/build under 'Additional arguments' in the qmake Build Step. If running qmake directly, add CMAKE_DIR=/path/to/renderdoc/build/ to the command line.")
	# }

	# DESTDIR=${CMAKE_SOURCE_DIR}/bin

	# include(${CMAKE_SOURCE_DIR}/qrenderdoc/qrenderdoc_cmake.pri)

	# # Temp files into .obj
	# MOC_DIR = .obj
	# UI_DIR = .obj
	# RCC_DIR = .obj
	# OBJECTS_DIR = .obj

	# # Link against the core library
	# LIBS -lrenderdoc
	# QMAKE_LFLAGS '-Wl,-rpath,\'\$$ORIGIN\',-rpath,\'\$$ORIGIN/../lib'$$LIB_SUFFIX'/'$$LIB_SUBFOLDER_TRAIL_SLASH'\''

	# # Add the SWIG files that were generated in cmake
	# SOURCES ${CMAKE_SOURCE_DIR}/qrenderdoc/renderdoc_python.cxx
	# SOURCES ${CMAKE_SOURCE_DIR}/qrenderdoc/qrenderdoc_python.cxx

	# CONFIG warn_off
	# CONFIG c++14
	# QMAKE_CFLAGS_WARN_OFF -= -w
	# QMAKE_CXXFLAGS_WARN_OFF -= -w

	# macx: {
	# 	SOURCES Code/AppleUtils.mm

	# 	LIBS -framework Cocoa -framework QuartzCore

	# 	DEFINES RENDERDOC_PLATFORM_POSIX RENDERDOC_PLATFORM_APPLE
	# 	ICON = $$OSX_ICONFILE

	# 	# add qrc file with qt.conf
	# 	RESOURCES Resources/qtconf.qrc
		
	# 	librd.files = $$files($$DESTDIR/../lib/librenderdoc.dylib)
	# 	librd.path = Contents/lib
	# 	QMAKE_BUNDLE_DATA librd

	# 	INFO_PLIST_PATH = $$shell_quote($$DESTDIR/$${TARGET}.app/Contents/Info.plist)
	# 	QTPLUGINS_PATH = $$shell_quote($$DESTDIR/$${TARGET}.app/Contents/qtplugins)
	# 	QMAKE_POST_LINK ln -sf $$[QT_INSTALL_PLUGINS] $${QTPLUGINS_PATH} ;
	# 	QMAKE_POST_LINK sh  ${CMAKE_CURRENT_LIST_DIR}/../util/set_plist_version.sh $${RENDERDOC_VERSION}.0 $${INFO_PLIST_PATH}
	# } else {
	# 	QT x11extras
	# 	DEFINES RENDERDOC_PLATFORM_POSIX RENDERDOC_PLATFORM_LINUX RENDERDOC_WINDOWING_XLIB RENDERDOC_WINDOWING_XCB
	# 	QMAKE_LFLAGS '-Wl,--no-as-needed -rdynamic'
	# }
endif()

# Add our sources first so Qt Creator adds new files here

list(APPEND SOURCES Code/qrenderdoc.cpp 
    Code/qprocessinfo.cpp 
    Code/ReplayManager.cpp 
    Code/CaptureContext.cpp 
    Code/ScintillaSyntax.cpp 
    Code/QRDUtils.cpp 
    Code/MiniQtHelper.cpp 
    Code/BufferFormatter.cpp 
    Code/Resources.cpp 
    Code/RGPInterop.cpp 
    Code/pyrenderdoc/PythonContext.cpp 
    Code/Interface/QRDInterface.cpp 
    Code/Interface/Analytics.cpp 
    Code/Interface/ShaderProcessingTool.cpp 
    Code/Interface/PersistantConfig.cpp 
    Code/Interface/RemoteHost.cpp 
    Styles/StyleData.cpp 
    Styles/RDStyle/RDStyle.cpp 
    Styles/RDTweakedNativeStyle/RDTweakedNativeStyle.cpp 
    Windows/Dialogs/AboutDialog.cpp 
    Windows/Dialogs/CrashDialog.cpp 
    Windows/Dialogs/UpdateDialog.cpp 
    Windows/MainWindow.cpp 
    Windows/EventBrowser.cpp 
    Windows/TextureViewer.cpp 
    Windows/ShaderViewer.cpp 
    Windows/ShaderMessageViewer.cpp 
    Widgets/Extended/RDLineEdit.cpp 
    Widgets/Extended/RDTextEdit.cpp 
    Widgets/Extended/RDLabel.cpp 
    Widgets/Extended/RDMenu.cpp 
    Widgets/Extended/RDHeaderView.cpp 
    Widgets/Extended/RDToolButton.cpp 
    Widgets/Extended/RDDoubleSpinBox.cpp 
    Widgets/Extended/RDListView.cpp 
    Widgets/ComputeDebugSelector.cpp 
    Widgets/CustomPaintWidget.cpp 
    Widgets/ResourcePreview.cpp 
    Widgets/ThumbnailStrip.cpp 
    Widgets/ReplayOptionsSelector.cpp 
    Widgets/TextureGoto.cpp 
    Widgets/RangeHistogram.cpp 
    Widgets/CollapseGroupBox.cpp 
    Windows/Dialogs/TextureSaveDialog.cpp 
    Windows/Dialogs/CaptureDialog.cpp 
    Windows/Dialogs/LiveCapture.cpp 
    Widgets/Extended/RDListWidget.cpp 
    Windows/APIInspector.cpp 
    Windows/DescriptorViewer.cpp 
    Windows/PipelineState/PipelineStateViewer.cpp 
    Windows/PipelineState/VulkanPipelineStateViewer.cpp 
    Windows/PipelineState/D3D11PipelineStateViewer.cpp 
    Windows/PipelineState/D3D12PipelineStateViewer.cpp 
    Windows/PipelineState/GLPipelineStateViewer.cpp 
    Widgets/Extended/RDTreeView.cpp 
    Widgets/Extended/RDTreeWidget.cpp 
    Widgets/BufferFormatSpecifier.cpp 
    Windows/BufferViewer.cpp 
    Widgets/Extended/RDTableView.cpp 
    Windows/DebugMessageView.cpp 
    Windows/LogView.cpp 
    Windows/CommentView.cpp 
    Windows/StatisticsViewer.cpp 
    Windows/TimelineBar.cpp 
    Windows/Dialogs/SettingsDialog.cpp 
    Widgets/OrderedListEditor.cpp 
    Widgets/MarkerBreadcrumbs.cpp 
    Widgets/Extended/RDTableWidget.cpp 
    Windows/Dialogs/SuggestRemoteDialog.cpp 
    Windows/Dialogs/VirtualFileDialog.cpp 
    Windows/Dialogs/RemoteManager.cpp 
    Windows/Dialogs/ExtensionManager.cpp 
    Windows/PixelHistoryView.cpp 
    Widgets/PipelineFlowChart.cpp 
    Windows/Dialogs/EnvironmentEditor.cpp 
    Widgets/FindReplace.cpp 
    Widgets/Extended/RDSplitter.cpp 
    Windows/Dialogs/TipsDialog.cpp 
    Windows/Dialogs/ConfigEditor.cpp 
    Windows/PythonShell.cpp 
    Windows/Dialogs/PerformanceCounterSelection.cpp 
    Windows/PerformanceCounterViewer.cpp 
    Windows/ResourceInspector.cpp 
    Windows/Dialogs/AnalyticsConfirmDialog.cpp 
    Windows/Dialogs/AnalyticsPromptDialog.cpp 
    Windows/Dialogs/AxisMappingDialog.cpp
)
list(APPEND HEADERS Code/CaptureContext.h 
    Code/qprocessinfo.h 
    Code/ReplayManager.h 
    Code/ScintillaSyntax.h 
    Code/QRDUtils.h 
    Code/MiniQtHelper.h 
    Code/Resources.h 
    Code/RGPInterop.h 
    Code/pyrenderdoc/PythonContext.h 
    Code/pyrenderdoc/pyconversion.h 
    Code/pyrenderdoc/interface_check.h 
    Code/Interface/QRDInterface.h 
    Code/Interface/Analytics.h 
    Code/Interface/PersistantConfig.h 
    Code/Interface/Extensions.h 
    Code/Interface/RemoteHost.h 
    Styles/StyleData.h 
    Styles/RDStyle/RDStyle.h 
    Styles/RDTweakedNativeStyle/RDTweakedNativeStyle.h 
    Windows/Dialogs/AboutDialog.h 
    Windows/Dialogs/CrashDialog.h 
    Windows/Dialogs/UpdateDialog.h 
    Windows/MainWindow.h 
    Windows/EventBrowser.h 
    Windows/TextureViewer.h 
    Windows/ShaderViewer.h 
    Windows/ShaderMessageViewer.h 
    Widgets/Extended/RDLineEdit.h 
    Widgets/Extended/RDTextEdit.h 
    Widgets/Extended/RDLabel.h 
    Widgets/Extended/RDMenu.h 
    Widgets/Extended/RDHeaderView.h 
    Widgets/Extended/RDToolButton.h 
    Widgets/Extended/RDDoubleSpinBox.h 
    Widgets/Extended/RDListView.h 
    Widgets/ComputeDebugSelector.h 
    Widgets/CustomPaintWidget.h 
    Widgets/ResourcePreview.h 
    Widgets/ThumbnailStrip.h 
    Widgets/ReplayOptionsSelector.h 
    Widgets/TextureGoto.h 
    Widgets/RangeHistogram.h 
    Widgets/CollapseGroupBox.h 
    Windows/Dialogs/TextureSaveDialog.h 
    Windows/Dialogs/CaptureDialog.h 
    Windows/Dialogs/LiveCapture.h 
    Widgets/Extended/RDListWidget.h 
    Windows/APIInspector.h 
    Windows/PipelineState/PipelineStateViewer.h 
    Windows/PipelineState/VulkanPipelineStateViewer.h 
    Windows/PipelineState/D3D11PipelineStateViewer.h 
    Windows/PipelineState/D3D12PipelineStateViewer.h 
    Windows/PipelineState/GLPipelineStateViewer.h 
    Widgets/Extended/RDTreeView.h 
    Widgets/Extended/RDTreeWidget.h 
    Widgets/BufferFormatSpecifier.h 
    Windows/BufferViewer.h 
    Widgets/Extended/RDTableView.h 
    Windows/DebugMessageView.h 
    Windows/LogView.h 
    Windows/CommentView.h 
    Windows/StatisticsViewer.h 
    Windows/TimelineBar.h 
    Windows/Dialogs/SettingsDialog.h 
    Widgets/OrderedListEditor.h 
    Widgets/MarkerBreadcrumbs.h 
    Widgets/Extended/RDTableWidget.h 
    Windows/Dialogs/SuggestRemoteDialog.h 
    Windows/Dialogs/VirtualFileDialog.h 
    Windows/Dialogs/RemoteManager.h 
    Windows/Dialogs/ExtensionManager.h 
    Windows/PixelHistoryView.h 
    Widgets/PipelineFlowChart.h 
    Windows/Dialogs/EnvironmentEditor.h 
    Widgets/FindReplace.h 
    Widgets/Extended/RDSplitter.h 
    Windows/Dialogs/TipsDialog.h 
    Windows/Dialogs/ConfigEditor.h 
    Windows/PythonShell.h 
    Windows/Dialogs/PerformanceCounterSelection.h 
    Windows/PerformanceCounterViewer.h 
    Windows/ResourceInspector.h 
    Windows/Dialogs/AnalyticsConfirmDialog.h 
    Windows/Dialogs/AnalyticsPromptDialog.h 
    Windows/Dialogs/AxisMappingDialog.h
)
list(APPEND FORMS
    Windows/Dialogs/AboutDialog.ui 
    Windows/Dialogs/CrashDialog.ui 
    Windows/Dialogs/UpdateDialog.ui 
    Windows/MainWindow.ui 
    Windows/EventBrowser.ui 
    Windows/TextureViewer.ui 
    Widgets/ResourcePreview.ui 
    Widgets/ThumbnailStrip.ui 
    Widgets/ReplayOptionsSelector.ui 
    Windows/Dialogs/TextureSaveDialog.ui 
    Windows/Dialogs/CaptureDialog.ui 
    Windows/Dialogs/LiveCapture.ui 
    Windows/APIInspector.ui 
    Windows/PipelineState/PipelineStateViewer.ui 
    Windows/PipelineState/VulkanPipelineStateViewer.ui 
    Windows/PipelineState/D3D11PipelineStateViewer.ui 
    Windows/PipelineState/D3D12PipelineStateViewer.ui 
    Windows/PipelineState/GLPipelineStateViewer.ui 
    Widgets/BufferFormatSpecifier.ui 
    Widgets/ComputeDebugSelector.ui 
    Windows/BufferViewer.ui 
    Windows/ShaderViewer.ui 
    Windows/ShaderMessageViewer.ui 
    Windows/DebugMessageView.ui 
    Windows/LogView.ui 
    Windows/CommentView.ui 
    Windows/StatisticsViewer.ui 
    Windows/Dialogs/SettingsDialog.ui 
    Windows/Dialogs/SuggestRemoteDialog.ui 
    Windows/Dialogs/VirtualFileDialog.ui 
    Windows/Dialogs/RemoteManager.ui 
    Windows/Dialogs/ExtensionManager.ui 
    Windows/PixelHistoryView.ui 
    Windows/Dialogs/EnvironmentEditor.ui 
    Widgets/FindReplace.ui 
    Windows/Dialogs/TipsDialog.ui 
    Windows/Dialogs/ConfigEditor.ui 
    Windows/PythonShell.ui 
    Windows/Dialogs/PerformanceCounterSelection.ui 
    Windows/PerformanceCounterViewer.ui 
    Windows/ResourceInspector.ui 
    Windows/Dialogs/AnalyticsConfirmDialog.ui 
    Windows/Dialogs/AnalyticsPromptDialog.ui 
    Windows/Dialogs/AxisMappingDialog.ui
)

list(APPEND RESOURCES Resources/resources.qrc)

# Add ToolWindowManager

list(APPEND SOURCES 3rdparty/toolwindowmanager/ToolWindowManager.cpp 
    3rdparty/toolwindowmanager/ToolWindowManagerArea.cpp 
    3rdparty/toolwindowmanager/ToolWindowManagerSplitter.cpp 
    3rdparty/toolwindowmanager/ToolWindowManagerTabBar.cpp 
    3rdparty/toolwindowmanager/ToolWindowManagerWrapper.cpp)

    list(APPEND HEADERS 3rdparty/toolwindowmanager/ToolWindowManager.h 
    3rdparty/toolwindowmanager/ToolWindowManagerArea.h 
    3rdparty/toolwindowmanager/ToolWindowManagerSplitter.h 
    3rdparty/toolwindowmanager/ToolWindowManagerTabBar.h 
    3rdparty/toolwindowmanager/ToolWindowManagerWrapper.h)

# Add FlowLayout

list(APPEND SOURCES 3rdparty/flowlayout/FlowLayout.cpp)
list(APPEND HEADERS 3rdparty/flowlayout/FlowLayout.h)

# Add Scintilla last as it has extra search paths

# Needed for building
list(APPEND DEFINES SCINTILLA_QT=1 MAKING_LIBRARY=1 SCI_LEXER=1)
list(APPEND INCLUDEPATH  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/src)
list(APPEND INCLUDEPATH  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/lexlib)

# list(APPEND SOURCES  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/lexlib/*.cxx 
#      ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/lexers/*.cxx 
#      ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/src/*.cxx 
#      ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/qt/ScintillaEdit/*.cpp 
#      ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/qt/ScintillaEditBase/*.cpp
# )
# list(APPEND HEADERS  ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/lexlib/*.h 
#      ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/src/*.h 
#      ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/qt/ScintillaEdit/*.h 
#      ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/qt/ScintillaEditBase/*.h
# )

set(search_paths
    ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/lexlib/
    ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/lexers/
    ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/src/
    ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/qt/ScintillaEdit/
    ${CMAKE_CURRENT_LIST_DIR}/3rdparty/scintilla/qt/ScintillaEditBase/
    # ${CMAKE_SOURCE_DIR}/x64/Development/obj/qrenderdoc/generated
)
set(source_cpp_list)
get_source_cpp_list(source_cpp_list ${search_paths})
list(REMOVE_DUPLICATES source_cpp_list)
list(APPEND SOURCES ${source_cpp_list})

# EXCLUDE_FILES(SOURCES GLOB_RECURSE 
#     ${CMAKE_SOURCE_DIR}/x64/Development/obj/qrenderdoc/generated/qrenderdoc_python.cxx
# )
# EXCLUDE_FILES(SOURCES GLOB_RECURSE 
#     ${CMAKE_SOURCE_DIR}/x64/Development/obj/qrenderdoc/generated/renderdoc_python.cxx
# )
#message("SOURCES:${SOURCES}")

set(include_dires
    ${CMAKE_CURRENT_LIST_DIR}
    3rdparty
    ${CMAKE_CURRENT_LIST_DIR}/../renderdoc/api/replay
    ${CMAKE_CURRENT_LIST_DIR}/3rdparty/python/include
    # ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/PySide2
    # ${CMAKE_CURRENT_LIST_DIR}/3rdparty/pyside/include/shiboken2

    # ${CMAKE_CURRENT_LIST_DIR}/3rdparty/qt/include
    # ${CMAKE_CURRENT_LIST_DIR}/3rdparty/qt/include/QtWidgets
    # ${CMAKE_CURRENT_LIST_DIR}/3rdparty/qt/include/QtGui
    # ${CMAKE_CURRENT_LIST_DIR}/3rdparty/qt/include/QtCore
    # ${CMAKE_CURRENT_LIST_DIR}/3rdparty/qt/include/QtSvg
    # ${CMAKE_CURRENT_LIST_DIR}/3rdparty/qt/include/QtNetwork
    # ${CMAKE_SOURCE_DIR}/x64/Development/obj/qrenderdoc/generated/
    ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG}
    ${CMAKE_SOURCE_DIR}/Renderdoc/build-win/x64/libs
)
get_include_directories(sub_include_dires ${search_paths})
list(REMOVE_DUPLICATES include_dires)
include_directories(${include_dires})





include_directories(${INCLUDEPATH})
list(APPEND DEFINES 
    # SWIGPYTHON
    # SWIG_GENERATED
    _CRT_SECURE_NO_WARNINGS
)
foreach(def ${DEFINES})
    add_definitions(-D${def})
endforeach()

if (WIN32)
    #使用unicode字符集
    add_win32_definitions()

    foreach(def ${QMAKE_CXXFLAGS})
        #add_definitions(-Wno-${def})
        add_compile_options(${def})
    endforeach()
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MD")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MD")
    
    build_executable( # Sets the name of the library.
        ${MODULE_NAME}
        WIN32
        ${SOURCES}
        ${HEADERS}
        ${RC_FILE}
        ${RESOURCES}
    )
    my_set_target_startup(${CMAKE_SOURCE_DIR} ${MODULE_NAME})
    my_set_target_folder(${MODULE_NAME} "UI")
    target_precompile_headers(${MODULE_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/Code/precompiled.h)

    # line qt
    target_link_libraries(${MODULE_NAME} 
            ${QT_LIB_PATH}/lib/Qt5Core.lib
            ${QT_LIB_PATH}/lib/Qt5Gui.lib
            ${QT_LIB_PATH}/lib/Qt5Network.lib
            ${QT_LIB_PATH}/lib/Qt5Svg.lib
            ${QT_LIB_PATH}/lib/Qt5Widgets.lib
            ${QT_LIB_PATH}/lib/qtmain.lib
    )

    target_link_libraries(${MODULE_NAME}
        #rdoc
        renderdoc
        rdoc_version
        user32.lib
        ${LIBS}
    )

else()
    foreach(def ${QMAKE_CXXFLAGS})
        #add_definitions(-Wno-${def})
        add_definitions(${def})
    endforeach()
    build_executable(
        ${MODULE_NAME}
        ${SOURCES}
        ${HEADERS}
        ${RC_FILE}
        ${RESOURCES}
    )
endif()