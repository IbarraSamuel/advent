use advent;

fn main() {
    let path = "../advent_config.toml";
    let toml = advent::advent_utils::read_toml(path.into());
    let _ = dbg!(toml);
}
