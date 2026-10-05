# Campus Academic API

Campus 教务服务的公共 gRPC 契约，供后端和私有 Academic 服务共同依赖。仅包含 protobuf 源文件和生成的 Go 类型、客户端及服务端接口。

## 使用

模块为 `github.com/LDouble/campus-academic-api`，包位于 `pkg/academic/provider/v1` 和 `pkg/academic/analytics/v1`。消费者固定发布版本。

## 修改与发布

修改 `proto/` 后运行 `make generate`，提交源文件和生成文件，并运行 `make generate-check` 和 `make test`。生成器版本由 `buf.gen.yaml` 固定。PR CI 执行 Buf breaking 检查。保留服务名和字段编号；破坏性变更应使用新的协议版本。

公共契约先发布，消费者随后升级。业务实现、数据库、配置与凭据留在私有 Academic 仓库。
