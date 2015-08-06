# Surrogator-Uploader

Surrogator-Uploader は[surrogator](https://github.com/cweiske/surrogator)のユーティリティサイトです。
surrogator はシンプルな仕組みのため、ユーザーがアイコンを設置するためには、サーバー内の raw/ にアクセスする必要があります。
ユーザーが内部構造を気にせずアイコンをアップロードできるようにしたのが、Surrogator-Uploaderです。

Surrogator-Uploaderは、ログインにLDAPを使っています。

## Usage
1. Surrogator-Uploader をサーバー内に設置してください。
2. setting.yml に情報を記載してください。
3. sinatraにて作成しているため、rackup もしくは passengerなどにて起動できます。
