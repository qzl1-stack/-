import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtQuick.Dialogs 6.3

ApplicationWindow {
    id: root
    width: 1200
    height: 800
    visible: true
    title: "文本分析器"
    color: "#FFFFFF"

    // 使用 Material 主题
    Material.theme: Material.Light
    Material.accent: Material.Blue

    property string searchText: ""
    property string fileContent: ""
    property bool isSearching: false
    
    // 顶部工具栏
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: "#FFFFFF"
        
        // 添加阴影效果
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: parent.height
            height: 4
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#20000000" }
                GradientStop { position: 1.0; color: "#00000000" }
            }
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // 标题
            Text {
                text: "文本分析器"
                font.pixelSize: 24
                font.bold: true
                color: Material.accent
                Layout.alignment: Qt.AlignVCenter
            }
            
            Item { Layout.fillWidth: true }
            
            // 搜索框容器
            Rectangle {
                Layout.preferredWidth: 400
                Layout.preferredHeight: 40
                color: "#F8FAFC"
                border.color: searchInput.activeFocus ? Material.accent : "#E2E8F0"
                border.width: 2
                radius: 8
                
                Behavior on border.color {
                    ColorAnimation { duration: 200 }
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    
                    // 搜索图标
                    Rectangle {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        color: "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🔍"
                            font.pixelSize: 16
                            color: "#64748B"
                        }
                    }
                    
                    // 搜索输入框
                    TextField {
                        id: searchInput
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: 14
                        color: "#1E293B"
                        placeholderText: text.length === 0 ? "输入关键词搜索..." : ""
                        anchors.verticalCenter: parent.verticalCenter
                        
                        background: Rectangle {
                            color: "transparent"
                        }
                        
                        onTextChanged: {
                            searchText = text
                            if (text.length > 0) {
                                searchTimer.restart()
                            } else {
                                textDisplay.text = root.formatForRichText(fileContent)
                            }
                        }
                        
                        Keys.onReturnPressed: performSearch()
                    }
                    
                    // 清除按钮
                    Button {
                        text: "✕"
                        visible: searchInput.text.length > 0
                        onClicked: {
                            searchInput.text = ""
                            searchInput.forceActiveFocus()
                        }
      
                    }
                }
            }
            
            // 文件操作按钮
            Button {
                text: "加载文件"
                Layout.preferredWidth: 120
                Layout.preferredHeight: 40
                
                onClicked: {
                    fileDialog.open()
                }
            }
        }
    }
    
    // 主内容区域
    Rectangle {
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: statusBar.top
        color: "#FFFFFF"
        
        // 侧边栏（搜索结果）
        Rectangle {
            id: sidebar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: (searchText.length > 0 && resultsModel.count > 0) ? 300 : 0  // 只有在有结果时才显示
            color: "#F8FAFC"
            border.color: "#E2E8F0"
            border.width: width > 0 ? 1 : 0
            
            // 使用更快的动画
            Behavior on width {
                NumberAnimation { 
                    duration: 200  // 减少到 200ms
                    easing.type: Easing.OutQuart  // 使用更快的缓动
                }
            }
            
            visible: width > 0
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                // 添加搜索状态指示
                Row {
                    width: parent.width
                    spacing: 10
                    
                    Text {
                        text: "搜索结果"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#1E293B"
                    }
                    
                    // 搜索进度指示器
                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: isSearching ? Material.accent : "transparent"
                        visible: isSearching
                        
                        RotationAnimator {
                            target: parent
                            from: 0
                            to: 360
                            duration: 1000
                            running: isSearching
                            loops: Animation.Infinite
                        }
                    }
                    
                    Text {
                        text: resultsModel.count > 0 ? "(" + resultsModel.count + ")" : ""
                        font.pixelSize: 12
                        color: "#64748B"
                        visible: !isSearching
                    }
                }
                
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#E2E8F0"
                }
                
                ScrollView {
                    width: parent.width
                    height: parent.height - 60  // 调整高度以适应新的标题行
                    
                    ListView {
                        id: searchResults
                        model: ListModel {
                            id: resultsModel
                        }
                        
                        // 启用缓存以提高性能
                        cacheBuffer: 1000
                        
                        delegate: Rectangle {
                            width: searchResults.width
                            height: 60
                            color: {
                                if (resultMouseArea.containsMouse) return "#EFF6FF"
                                return "transparent"
                            }
                            radius: 6
                            
                            // 添加边框效果
                            border.width: resultMouseArea.containsMouse ? 1 : 0
                            border.color: resultMouseArea.containsMouse ? "#DBEAFE" : "transparent"
                            
                            Behavior on color {
                                ColorAnimation { 
                                    duration: 300  
                                    easing.type: Easing.InOutQuad
                                }
                            }
                            
                            Behavior on border.color {
                                ColorAnimation { duration: 300 }  
                            }
                            
                            Rectangle {
                                anchors.fill: parent
                                anchors.topMargin: 2
                                anchors.leftMargin: 2
                                radius: parent.radius
                                color: "#08000000"  
                                visible: resultMouseArea.containsMouse
                                z: -1
                                
                                Behavior on visible {
                                    NumberAnimation { duration: 300 }  
                                }
                            }
                            
                            Column {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 10
                                
                                Text {
                                    text: "第 " + (model.lineNumber || 0) + " 行"
                                    font.pixelSize: 12
                                    color:  "#2563EB"   
                                    font.bold: resultMouseArea.containsMouse
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 300 }  
                                    }
                                }
                                
                                Text {
                                    text: model.preview || ""
                                    font.pixelSize: 11
                                    color: resultMouseArea.containsMouse ? "#1E293B" : "#64748B"  
                                    width: parent.width
                                    elide: Text.ElideRight
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 300 }  
                                    }
                                }
                            }
                            
                            MouseArea {
                                id: resultMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    root.jumpToLine(model.lineNumber || 0)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 文本显示区域
        Rectangle {
            anchors.top: parent.top
            anchors.left: sidebar.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            color: "#FFFFFF"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 0

                // 行号显示区域
                ScrollView {
                    id: lineNumberScrollView
                    Layout.preferredWidth: 70
                    Layout.fillHeight: true
                    clip: true
                    
                    // 隐藏滚动条，只显示内容
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    
                    // 添加拦截滚轮事件的 MouseArea
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        
                        // 完全拦截滚轮事件
                        onWheel: (wheel) => {
                            wheel.accepted = true  // 标记事件已处理，阻止传播
                        }
                    }
                    
                    TextArea {
                        id: lineNumberArea
                        readOnly: true
                        color: "#888888"
                        font.pixelSize: 14
                        font.family: "Consolas, Monaco, monospace"
                        background: Rectangle { color: "#F8FAFC" }
                        selectByMouse: false
                        
                        // 禁止鼠标交互
                        mouseSelectionMode: TextInput.NoSelection
                        activeFocusOnPress: false
                        
                        // 禁用输入和编辑
                        inputMethodHints: Qt.ImhNoPredictiveText
                        
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton  
                            propagateComposedEvents: false
                        }
                    }
                }

                // 文本内容显示区域
                ScrollView {
                    id: textScrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    // 明确指定滚动条在右侧
                    ScrollBar.vertical: ScrollBar { 
                        id: mainScrollBar
                        interactive: true 
                        anchors.right: parent.right  // 将滚动条锚定在右侧
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        
                        // 当滚动条位置改变时，同步行号区域
                        onPositionChanged: {
                            lineNumberScrollView.ScrollBar.vertical.position = position
                        }
                    }
                    ScrollBar.horizontal.policy: ScrollBar.AsNeeded

                    TextArea {
                        id: textDisplay
                        readOnly: true
                        selectByMouse: true
                        wrapMode: TextArea.NoWrap
                        font.family: "Consolas, Monaco, monospace"
                        font.pixelSize: 14
                        color: "#1E293B"
                        textFormat: Text.RichText
                        background: Rectangle { color: "transparent" }

                        // 当文本变化时，更新行号
                        onTextChanged: updateLineNumbers()
                        
                        property var searchResults: []
                    }
                }
            }
            
            // 空状态提示
            Column {
                anchors.centerIn: parent
                spacing: 20
                visible: fileContent.length === 0
                
                Text {
                    text: "📄"
                    font.pixelSize: 64
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "暂无文本内容"
                    font.pixelSize: 18
                    color: "#64748B"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "点击\"加载文件\"按钮来导入文本文件"
                    font.pixelSize: 14
                    color: "#94A3B8"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
    
    // 底部状态栏
    Rectangle {
        id: statusBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        color: "#F8FAFC"
        border.color: "#E2E8F0"
        border.width: 1
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            
            Text {
                text: fileContent.length > 0 ? "文件已加载 | 字符数: " + fileContent.length : "就绪"
                font.pixelSize: 12
                color: "#64748B"
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: searchText.length > 0 ? "搜索: \"" + searchText + "\"" : ""
                font.pixelSize: 12
                color: Material.accent
                visible: searchText.length > 0
            }
            
            // 加载进度指示器
            ProgressBar {
                id: loadingIndicator
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignVCenter
                visible: false
                from: 0
                to: 100
                value: 0
            }
        }
    }
    
    // 搜索延迟定时器 - 增加延迟时间
    Timer {
        id: searchTimer
        interval: 500  // 增加到 500ms，减少搜索频率
        onTriggered: performSearch()
    }
    
    // 添加搜索取消定时器
    Timer {
        id: searchCancelTimer
        interval: 50
        onTriggered: {
            // 取消当前搜索
            isSearching = false
        }
    }
    
    // 行高亮定时器
    Timer {
        id: highlightTimer
        interval: 100
        property int targetLine: 0
        
        onTriggered: {
            // 添加临时高亮效果
            if (targetLine > 0) {
                // 这里可以添加高亮逻辑，比如临时改变目标行的背景色
                console.log("跳转到第", targetLine, "行")
            }
        }
    }
    
    // 优化的搜索功能
    function performSearch() {
        if (searchText.length === 0 || fileContent.length === 0) {
            textDisplay.text = root.formatForRichText(fileContent)
            resultsModel.clear()
            updateLineNumbers()
            return
        }
        
        // 防止重复搜索
        if (isSearching) {
            searchCancelTimer.restart()
            return
        }
        
        isSearching = true
        resultsModel.clear()
        
        // 分批处理大文本
        var lines = fileContent.split('\n')
        var batchSize = 100  // 每批处理100行
        var currentBatch = 0
        var totalBatches = Math.ceil(lines.length / batchSize)
        
        var highlightedContent = ""
        var results = []
        var searchRegex = new RegExp(searchText.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'), 'gi');
        
        // 限制搜索结果数量，提高性能
        var maxResults = 100
        var resultCount = 0
        
        function processBatch() {
            if (!isSearching || resultCount >= maxResults) {
                isSearching = false
                return
            }
            
            var startIndex = currentBatch * batchSize
            var endIndex = Math.min(startIndex + batchSize, lines.length)
            
            for (var i = startIndex; i < endIndex && resultCount < maxResults; i++) {
                var line = lines[i]
                
                if (line.match(searchRegex)) {
                    var preview = line.length > 50 ? line.substring(0, 50) + "..." : line
                    resultsModel.append({
                        lineNumber: i + 1,
                        preview: preview
                    })
                    
                    results.push({ lineNumber: i + 1, text: line })
                    resultCount++
                    
                    // 高亮显示
                    var result = ""
                    var lastIndex = 0
                    var match
                    searchRegex.lastIndex = 0 // Reset regex
                    while ((match = searchRegex.exec(line)) !== null) {
                        result += root.formatForRichText(line.substring(lastIndex, match.index), false)
                        result += '<span style="background-color: #DBEAFE; color: #1D4ED8; font-weight: bold;">' + root.formatForRichText(match[0], false) + '</span>'
                        lastIndex = searchRegex.lastIndex
                    }
                    result += root.formatForRichText(line.substring(lastIndex), false)
                    highlightedContent += result
                } else {
                    highlightedContent += root.formatForRichText(line, false)
                }
                
                if (i < lines.length - 1) {
                    highlightedContent += '<br>'
                }
            }
            
            currentBatch++
            
            // 如果还有更多批次需要处理，使用 Qt.callLater 延迟处理
            if (currentBatch < totalBatches && isSearching && resultCount < maxResults) {
                Qt.callLater(processBatch)
            } else {
                // 搜索完成
                textDisplay.text = highlightedContent
                textDisplay.searchResults = results
                updateLineNumbers()
                isSearching = false
            }
        }
        
        // 开始处理第一批
        Qt.callLater(processBatch)
    }

    function jumpToLine(lineNumber) {
        if (lineNumber <= 0) return

        var lines = fileContent.split('\n')
        if (lineNumber > lines.length) return
        
        var position = 0
        for (var i = 0; i < lineNumber - 1 && i < lines.length; i++) {
            position += lines[i].length + 1
        }
        textDisplay.cursorPosition = position
        
        var lineHeight = textDisplay.font.pixelSize * 1.2  
        
        var targetLinePixelPosition = (lineNumber - 1) * lineHeight
        
        var viewportHeight = textScrollView.height
        
        var targetScrollPosition = targetLinePixelPosition - (viewportHeight / 2)
        
        var maxScrollPosition = Math.max(0, textDisplay.contentHeight - viewportHeight)
        targetScrollPosition = Math.max(0, Math.min(targetScrollPosition, maxScrollPosition))
        
        var scrollBarPosition = maxScrollPosition > 0 ? targetScrollPosition / maxScrollPosition : 0
        
        mainScrollBar.position = scrollBarPosition
        
        lineNumberScrollView.ScrollBar.vertical.position = scrollBarPosition
        
        highlightTimer.targetLine = lineNumber
        highlightTimer.restart()
    }
    
    function formatForRichText(plainText, handleNewlines = true) {
        var richText = plainText.replace(/&/g, "&amp;")
                                .replace(/</g, "&lt;")
                                .replace(/>/g, "&gt;");
        if (handleNewlines) {
            richText = richText.replace(/\n/g, '<br>');
        }
        return richText;
    }

    // 错误对话框
    Dialog {
        id: errorDialog
        title: "文件加载错误"
        anchors.centerIn: parent
        standardButtons: Dialog.Ok
        
        property string errorText: ""
        
        Label {
            anchors.fill: parent
            text: errorDialog.errorText
            wrapMode: Text.Wrap
        }
    }

    // 文件对话框
    FileDialog {
        id: fileDialog
        title: "选择文本文件"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Text Files (*.txt *.log *.md *.csv)", "All Files (*)"]
        
        onAccepted: function() {
            // 处理文件选择
            if (typeof fileHandler !== 'undefined') {
                // 显示加载进度
                loadingIndicator.value = 0
                loadingIndicator.visible = true
                
                // 异步加载文件
                fileHandler.loadTextFileAsync(selectedFile)
            }
        }
    }

    // 文件加载信号处理
    Connections {
        target: fileHandler
        
        function onFileLoaded(content) {
            if (content.length > 0) {
                fileContent = content
                textDisplay.text = root.formatForRichText(fileContent)
                loadingIndicator.visible = false
                updateLineNumbers() // 加载文件后更新行号
            } else {
                loadSampleText()
            }
        }
        
        function onLoadProgress(progress) {
            loadingIndicator.value = progress
        }
        
        function onLoadError(errorMessage) {
            loadingIndicator.visible = false
            errorDialog.errorText = errorMessage
            errorDialog.open()
        }
    }

    // 更新行号的函数
    function updateLineNumbers() {
        var lineCount = textDisplay.lineCount
        var numbers = ""
        for (var i = 1; i <= lineCount; i++) {
            numbers += i + "\n"
        }
        lineNumberArea.text = numbers
    }
}
