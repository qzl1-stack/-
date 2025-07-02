#ifndef TEXTFILEHANDLER_H
#define TEXTFILEHANDLER_H

#include <QObject>
#include <QString>
#include <QFile>
#include <QFileDialog>
#include <QTextStream>
#include <QMessageBox>
#include <QStringConverter>
#include <QThread>
#include <QRunnable>
#include <QThreadPool>
#include <atomic>

class TextFileHandler : public QObject {
    Q_OBJECT

public:
    explicit TextFileHandler(QObject *parent = nullptr);

public slots:
    /**
     * @brief 异步加载文本文件
     * @param fileName 可选的文件路径，如果为空则弹出文件选择对话框
     */
    Q_INVOKABLE void loadTextFileAsync(const QString &fileName = QString());

    /**
     * @brief 取消文件加载
     */
    Q_INVOKABLE void cancelFileLoading();

signals:
    /**
     * @brief 文件加载进度信号
     * @param progress 加载进度（0-100）
     */
    void loadProgress(int progress);

    /**
     * @brief 文件加载完成信号
     * @param content 文件内容
     */
    void fileLoaded(const QString &content);

    /**
     * @brief 文件加载错误信号
     * @param errorMessage 错误信息
     */
    void loadError(const QString &errorMessage);

private:
    /**
     * @brief 显示文件操作错误消息
     * @param title 错误标题
     * @param message 错误消息
     */
    void showErrorMessage(const QString &title, const QString &message);

    // 标记是否取消加载
    std::atomic<bool> m_cancelLoading;
};

#endif // TEXTFILEHANDLER_H 