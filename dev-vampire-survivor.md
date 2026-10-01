# Game 001 — Phase 5 実装指示

Godot 4.x / GDScript で開発中の簡易ヴァンサバ系ゲームについて、Phase 5「HP・ダメージ・死亡」を実装してください。

## 前提

Phase 4まで実装済みです。

現在できていること：

- WASD / 矢印キーによるPlayer移動
- EnemyのPlayer追跡
- Enemyの継続スポーン
- Playerから最寄りEnemyへの自動攻撃
- BulletとEnemyの衝突
- Enemy撃破処理

既存コード・Scene構成を必ず確認し、現在正常に動作しているPhase 1〜4を壊さない形で実装してください。

不要なリファクタリングや大規模な設計変更は行わないでください。

# Phase 5の目的

以下を実装します。

1. Player HP
2. Enemy HP
3. Bulletの攻撃力
4. Enemyへのダメージ
5. Playerへの接触ダメージ
6. Playerの被弾後無敵時間
7. Player死亡
8. GAME OVER表示

## 1. Player HP

Playerの初期HPを以下とします。

- Max HP: `100`
- 初期HP: `100`

将来的にHP強化などを追加できる構造にしてください。

## 2. Enemy HP

通常Enemyの初期HP：

- HP: `3`

現在Phase 4で「BulletがEnemyに当たったら即削除」になっている場合、その処理を変更してください。

Bullet命中時：

```text
Enemy HP
3
↓
2
↓
1
↓
0
↓
Enemy死亡
```

EnemyはHPが0以下になった場合のみ削除してください。

## 3. Bullet攻撃力

通常Bullet：

- Damage: `1`

Bullet自身、Player、または適切な攻撃管理箇所に攻撃力を持たせて構いません。

ただしPhase 7で「攻撃力アップ」を実装予定なので、固定的にEnemyのHPを1減らすだけの構造にはしないでください。

概念として、

```text
Bullet
damage = 1

↓

Enemy
take_damage(damage)
```

のように、攻撃力とEnemy HPを分離してください。

## 4. EnemyからPlayerへの接触ダメージ

EnemyがPlayerに接触するとPlayerがダメージを受けるようにしてください。

初期値：

- Enemy contact damage: `10`

Player HP：

```text
100
↓
90
↓
80
...
```

## 5. Playerの無敵時間

Enemyと接触している間、毎フレームHPが減らないようにしてください。

Playerがダメージを受けた後：

- 無敵時間：`1.0秒`

無敵時間中はEnemyと接触しても追加ダメージを受けません。

例：

```text
Enemy接触
↓
HP 100 → 90
↓
1秒間無敵
↓
再びダメージ可能
```

実装方法は既存Scene構成に合わせて判断してください。

## 6. Player死亡

Player HPが `0以下` になったら死亡状態にしてください。

死亡後は最低限、以下を停止してください。

- Player移動
- Player自動攻撃
- Enemy新規スポーン

既存Enemyの扱いについては、最もシンプルで安全な方法を選んでください。

## 7. GAME OVER表示

Player死亡時、画面中央付近に

```text
GAME OVER
```

を表示してください。

Phase 5ではリトライボタン等は不要です。

## 8. デバッグ用HP表示

Phase 5の動作確認がしやすいように、画面上にPlayerの現在HPを表示してください。

例：

```text
HP: 100 / 100
```

ダメージを受けた場合：

```text
HP: 90 / 100
```

現時点では簡易UIで構いません。

# 完成条件

以下をすべてGodot上で確認してください。

- Player HPが100から開始する
- Enemy HPが3から開始する
- BulletのDamageが1
- EnemyはBullet 3発で死亡する
- Enemy接触でPlayerが10ダメージ受ける
- 接触し続けても毎フレームダメージにならない
- 被弾後1秒の無敵時間が機能する
- Player HPが0以下になると死亡する
- 死亡後Playerが移動しない
- 死亡後Playerが攻撃しない
- 死亡後Enemyが新規スポーンしない
- GAME OVERが表示される
- Playerの現在HPを画面上で確認できる
- Phase 1〜4の既存機能が壊れていない

# 実装方針

今回はゲーム開発学習用の小規模プロトタイプです。

以下を優先してください。

- シンプルな実装
- Godot標準のScene / Node / Signal構成
- 初心者でも追いやすいコード
- 不要な抽象化を避ける
- 不要なファイル追加を避ける
- 不要なリファクタリングをしない
- Phase 6以降へ最低限拡張可能な構造にする

Phase 6では「Enemy撃破 → XP獲得 → レベルアップ」を追加する予定です。

Enemy死亡処理は、Phase 6で撃破時にXPを発生させられることを考慮してください。

# 作業後の報告

実装完了後、以下を簡潔に報告してください。

1. 変更したファイル
2. 新規作成したファイル
3. HP / Damageの実装方法
4. Player無敵時間の実装方法
5. Game Overの実装方法
6. Godotでの動作確認結果
7. Phase 6へ進む際に注意すべき点

Phase 5以外の機能追加には進まないでください。