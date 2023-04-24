defmodule PullGit do
  use GenServer

  def init(state), do: {:ok, state}

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get(user) do
    GenServer.call(__MODULE__, {:get, user})
  end

  def state() do
    GenServer.call(__MODULE__, :state)
  end

  def handle_call({:get, user}, _from, state) do
    if Map.has_key?(state, user) do
      {:reply, Map.get(state, user), state}
    else
      with {:ok, result} <- HTTPoison.get("https://api.github.com/users/#{user}"),
           {:ok, data} <- Jason.decode(result.body),
           new_user = create_user(data) do
        {:reply, new_user, Map.put(state, user, new_user)}
      else
        {:error, reason} ->
          {:reply, {:error, reason}, state}
      end
    end
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  defp create_user(data) do
    %User{
      name: data["name"],
      email: data["email"],
      url: data["url"],
      created_at: data["created_at"],
      followers: data["followers"],
      following: data["following"]
    }
  end
end
