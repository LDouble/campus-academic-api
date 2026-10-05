# Academic API 开发指南

本仓库是 Campus 教务 gRPC 契约的唯一来源，默认分支为 `master`。仓库公开，业务实现由私有 `campus-academic` 维护，平台 HTTP/OpenAPI 由 backend 维护。

## 目录与公开边界

- `proto/academic/provider/v1`：Provider 服务与消息的源契约。
- `proto/academic/analytics/v1`：Analytics、Recipient、Timetable 服务与消息的源契约。
- `pkg/academic/*/v1`：生成的 Go 类型、客户端和服务端接口，不手工修改。
- `buf.yaml`、`buf.gen.yaml`：lint、兼容检查及固定版本生成器的配置。
- 只发布契约、生成代码、模块元数据、开发文档和检查配置；不复制私有实现、部署配置、账号数据、凭据或私有 Git 历史。
- 内部 RPC 的公开定义不授予调用权限；保留服务端 mTLS、身份校验和访问限制，不在契约迁移中绕过这些规则。

## 契约修改与验证

1. 先核对 backend 客户端与 Academic 服务端的实际使用。修改源 proto，再运行 `make generate`；不要在消费者仓库复制另一套协议。
2. 已发布的 package、服务/方法名、字段编号和枚举语义保持兼容。新增字段采用兼容扩展；删除字段保留编号和名称，不复用。破坏性变更使用新的协议版本，并明确旧版本退出流程。
3. 生成前后的差异必须与源变更一致。提交前运行 `make generate-check`、`make test`、`go vet ./...` 和 `git diff --check`；PR CI 对默认分支执行 Buf breaking 检查。
4. Go module 变更执行 `go mod tidy`。使用 `GOWORK=off` 检查模块能独立编译；不要用本地 `replace` 或工作区配置代替消费者验收。

## 跨仓库发布

- 公共契约先通过审查与 CI 并发布可匿名下载的固定版本，然后分别升级 backend 和 Academic。相关 PR 互相链接，记录契约版本或提交。
- 消费者固定版本，不能依赖分支名或 latest。发布新版本时使用全新模块缓存、无私有 Git 凭据验证匿名下载与 checksum。
- 消费者已引用 PR 提交的 pseudo-version 时，以 merge commit 合并，保留该提交可从默认分支追溯；不要 squash/rebase 后删除唯一可达分支。若必须改写历史，先发布新的可达版本并更新所有消费者。
- 私有 Academic 仓库保持私有。后端镜像的 Go 编译只依赖公共 API；GitHub 的真实服务集成测试所需私有源码权限是另一条链路，不把测试权限误当成 ACR 编译需求。
- 合并前检查当前 head 的全部 CI 与审查；逐仓确认 commit、远端和 PR head 一致。合并、镜像构建和部署分别报告，不把合并当作部署完成。

新任务先获取最新默认分支并创建独立工作分支；同一未合并 PR 的评审修正继续使用原分支。多仓库 worktree 和发布规则同时遵守 campus-workspace 根规范。
