#include "textfilehandler.h"
#include <QFileInfo>
#include <QUrl>

TextFileHandler::TextFileHandler(QObject *parent) 
    : QObject(parent), m_cancelLoading(false) {}

void TextFileHandler::loadTextFileAsync(const QString &fileName) {
    // 重置取消标志
    m_cancelLoading = false;

    // 如果没有传入文件名，则弹出文件选择对话框
    QString selectedFileName = fileName;
    if (selectedFileName.isEmpty()) {
        selectedFileName = QFileDialog::getOpenFileName(
            nullptr,
            "选择文本文件",
            "",
            "文本文件 (*.txt *.log *.md *.csv);;所有文件 (*)"
        );
    } else {
        // 处理 QUrl 格式的文件路径
        QUrl url(selectedFileName);
        selectedFileName = url.toLocalFile();
    }
    
    if (selectedFileName.isEmpty()) {
        emit loadError("未选择文件");
        return;
    }

    // 在单独的线程中加载文件
    QThread* thread = new QThread();
    QObject* worker = new QObject();
    worker->moveToThread(thread);

    // 连接信号和槽
    connect(thread, &QThread::started, [this, selectedFileName, thread, worker]() {
        try {
            // 获取文件大小
            QFileInfo fileInfo(selectedFileName);
            qint64 fileSize = fileInfo.size();

            // 打开文件
            QFile file(selectedFileName);
            if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
                emit loadError("无法打开文件：" + selectedFileName);
                QMetaObject::invokeMethod(QThread::currentThread(), "quit", Qt::QueuedConnection);
                return;
            }
            
            // 分块读取文件
            QTextStream in(&file);
            in.setEncoding(QStringConverter::Utf8);

            QString content;
            qint64 bytesRead = 0;
            const int CHUNK_SIZE = 1024 * 1024; // 1MB 分块大小

            while (!in.atEnd() && !m_cancelLoading) {
                content += in.read(CHUNK_SIZE);
                bytesRead += CHUNK_SIZE;

                // 计算并发送进度
                int progress = qMin(100, static_cast<int>((bytesRead * 100) / fileSize));
                emit loadProgress(progress);
            }

            file.close();

            // 检查是否被取消
            if (m_cancelLoading) {
                emit loadError("文件加载已取消");
            } else {
                emit fileLoaded(content);
            }
        } catch (const std::exception& e) {
            emit loadError(QString("加载错误：%1").arg(e.what()));
        }

        // 结束线程
        QMetaObject::invokeMethod(QThread::currentThread(), "quit", Qt::QueuedConnection);
    });

    // 清理资源
    connect(thread, &QThread::finished, thread, &QThread::deleteLater);
    connect(thread, &QThread::finished, worker, &QObject::deleteLater);

    // 启动线程
    thread->start();
}

void TextFileHandler::cancelFileLoading() {
    m_cancelLoading = true;
}

void TextFileHandler::showErrorMessage(const QString &title, const QString &message) {
    QMessageBox::warning(nullptr, title, message);
}

