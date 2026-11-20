defmodule Hex.SCMTest do
  use ExUnit.Case, async: true

  test "guess build_tools" do
    empty_meta = %{}
    guessed_meta = %{"build_tools" => ["mix"]}
    no_tools_meta = %{"files" => ["README.md"]}
    tools_meta = %{"files" => ["README.md", "mix.exs", "lib"]}

    assert [] = Hex.SCM.guess_build_tools(empty_meta)
    assert ["mix"] = Hex.SCM.guess_build_tools(guessed_meta)
    assert [] = Hex.SCM.guess_build_tools(no_tools_meta)
    assert ["mix"] = Hex.SCM.guess_build_tools(tools_meta)
  end

  test "prune_uri_userinfo masks userinfo and query values" do
    url =
      "https://user:secret@repo.example.com/hex/tarballs/pkg-1.0.0.tar?access_token=secret-value&tenant=acme"

    pruned = Hex.SCM.prune_uri_userinfo(url)

    assert pruned =~ "access_token=***"
    assert pruned =~ "tenant=***"
    assert pruned =~ "******"
    assert pruned =~ "/hex/tarballs/pkg-1.0.0.tar"
    refute pruned =~ "secret-value"
    refute pruned =~ "user:secret"

    plain = "https://repo.example.com/hex/tarballs/pkg-1.0.0.tar"
    assert Hex.SCM.prune_uri_userinfo(plain) == plain

    userinfo = "https://user:secret@repo.example.com/hex/tarballs/pkg-1.0.0.tar"

    assert Hex.SCM.prune_uri_userinfo(userinfo) ==
             "https://******@repo.example.com/hex/tarballs/pkg-1.0.0.tar"

    assert Hex.SCM.prune_uri_userinfo("https://repo.example.com/hex?raw") ==
             "https://repo.example.com/hex?raw"

    assert Hex.SCM.prune_uri_userinfo("https://repo.example.com/hex?access_token=") ==
             "https://repo.example.com/hex?access_token=***"
  end
end
