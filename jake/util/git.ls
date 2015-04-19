require! {
  'child_process': {spawn}

  'promise': Promise

  '../../build-config': {'git-path': git-path}
}


module.exports = (...args) ->
  resolve, reject <-! new Promise _
  proc = spawn git-path, args, do
    stdio: [\ignore \pipe 2]

  output = []
  proc.stdout.on \data (chunk) !-> output.push chunk
  proc.on \close (code, signal) !->
    | code is 0 => resolve Buffer.concat(output).toString!
    | code?     => reject "git exited with code #{code}"
    | otherwise => reject "git killed by signal #{signal}"
