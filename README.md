# Campus Academic API

Campus 教务服务的公共 gRPC 契约，供后端和私有 Academic 服务共同依赖。仅包含 protobuf 源文件和生成的 Go 类型、客户端及服务端接口。

## 使用

模块为 `github.com/LDouble/campus-academic-api`。消费者固定发布版本，各包位于 `pkg/academic/`：

- `provider/v1`：教务查询与绑定验证。
- `analytics/v1`：分析数据查询。
- `credentials/v1`：凭据生命周期、元数据及受控取用，平台身份与访问授权。
- `execution/v1`：Backend 任务准入与观察登记，Provider 单次查询及执行隔离。
- `archive/v1`：Analytics 已持久化的归档观察回执。

Backend 是业务任务的唯一状态权威；Credentials 不调度、存储或执行任务。Credentials 的旧 `UpdateGrant`、`CreateTask`、`GetTask`、`LeaseTask`、`ResolveTaskCredential`、`CheckExecutionAdmission` 和 `CompleteTask` RPC 仅保留协议兼容，已弃用，服务端无实现且不授权，生产运行时不得调用。

内部方法必须执行 mTLS 方法级授权。通用凭据访问由 Credentials 从真实 mTLS 对端取得调用方身份，向 Backend 校验与当前执行尝试绑定的一次性短票据；Backend 授权只读取自己的任务及身份状态，Credentials 随后独立核对本地凭据状态并原子消费访问标识。Provider 仅对当前凭据版本报告 `reauth_required` 或 `action_required`。

## 修改与发布

修改 `proto/` 后运行 `make generate`，提交源文件和生成文件，并运行 `make generate-check` 和 `make test`。生成器版本由 `buf.gen.yaml` 固定。PR CI 执行 Buf breaking 检查。保留服务名和字段编号；破坏性变更应使用新的协议版本。

公共契约先发布，消费者随后升级。业务实现、数据库、配置与凭据留在私有 Academic 仓库。
