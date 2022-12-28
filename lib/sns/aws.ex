defmodule SNS.AWS do
  import SNS.Config, only: [config!: 1]

  def config do
    [
      secret_access_key: config!(:secret_access_key),
      access_key_id: config!(:access_key_id),
      region: config!(:region),
      host: host_with_prefix(),
      scheme: config!(:scheme)
    ]
  end

  defp host_with_prefix do
    "sns.#{config!(:region)}.#{config!(:host)}"
  end
end
