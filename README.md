# SuperResolutionICCV2013
实现ICCV 2013----Fast Direct Super-Resolution by Simple Functions

## 描述算法: 
  文本采用统计SISR方法，与其它统计方法相比，本文所采用的方法计算资源得到 一定的优化。需要从训练集中提取出低分辨率的patch，和与之对应的高分辨率的 patch。然后把低分辨率patch的集合分为许多小聚类(并计算聚类中心)，每个聚 类选则一定数量的patch用来计算系数矩阵C，用来得到高分辨率的patch。最终将 得到所有聚类的系数矩阵。

## 具体步骤如下:
1 将高分辨率图像高斯模糊并下采样得到低分辨率图像
2 分别提取出高分辨率图像集的patch集合H，以及低分辨率图像集的patch集合 L;
3 将低分辨率图像集的patch集合L分为多个聚类(4096)，使用K-means算法即 可;
4 使用最小二乘法算出每个聚类的系数矩阵(相当于列出n个线性方程组)。

## 对于一张低分辨率的图像，将采用以下步骤来获取高分辨率的图像:
1 将这张图像提取出很多小低分辨率patch;
2 对于每个低分辨率patch，通过计算它与每一个聚类中心的距离来确定它属于哪 一个聚类;
3 在将所有低分辨率patch分类以后，分别乘上各自聚类的系数矩阵，得到每一个 低分辨率 对应的高分辨率patch;
4 将所有得到的高分辨率patch合成新的图像，这张图像就是最终得到的高分辨率 图像。

## 实现思路:
1 首先创建一个PicNameList.txt文件，用于保存训练集中所有图片的名字，图片名 字按照一定规则排序，便于统一管理;
2 从训练集的所有图片中提取出用于聚类的patch，保存它们各自在图像中的位置 坐标，权衡时间与效率，丢弃比较光滑的patch，加快速度。一张图像中一般来说 不平滑的部分是特征是特征最明显的部分。
3 随机选择训练需要的patch。因为每个patch的边长为7个像素，训练集中所有的 图片所产生的patch数量一共有300多万个，在PC上训练那么多所花费的计算资源 是相当大的，所以需要随机从中选取一部分来进行训练(选则20万)。
4 提取出这20万个pacth的特征，也就是说将这20万个patch全部提取出来分别按 照所属的图像文件归类存储，属于同一个图像文件的patch存储在同一个mat文件 中。每一个mat文件的行数为45(就是patch的像素数量)，列数为在各个图像文件 中随机挑选出来的patch的数量(并不是图像的全部patch)。
5 将20万patch分成4096个聚类，并运用K-means算法求出每个聚类的聚类中心。 这个阶段需要的计算资源比较大。
6 为选出来的20万份patch的每一个打上一个标签，用于标识它属于哪一个聚类。 核心算法很简单，就是直接将每个patch与4096个聚类中心计算距离，并将该 patch划分到离聚类中心距离最短的那个聚类。
7 计算每个聚类的系数C(w = C·v)，v是一个45维的向量，对应这低分辨率的 patch;w是一个81维的向量，对应着高分辨率的patch;C是一个行数为81列数为 45的矩阵。每个聚类选则1000个左右计算系数就行(节约开销)。
8 使用Set14测试集来测试。对于彩色图片，需要将rgb转换到yiq下，然后使用y来 进行计算目标高分辨率图像矩阵，i,q通道则直接使用双三次放大，因为人眼对亮度 通道更加敏感;如果是灰度图片，那么直接使用即可。最终得到的结果在文件夹 “TestReault”

基本超分辨率算法的实现请参见文件夹“5 基本超分辨率”
实现得到的结果路径为 “SuperResolutionICCV2013\Database\TestResult”
我已经全部训练好了，但是由于网站限制上传100M的文件，光是系数矩阵就有102M，所以
我只保留了“SuperResolutionICCV2013\Database”文件夹
然后按照Step0 -> Step8 的顺序依次运行
Step0是产生low resolution的图像集
Step1->Step8的说明请参见上述的实现思路的8个步骤
注：为了节省空间，我只保留了“SuperResolutionICCV2013\Database\TestResult”中的图片，如果需要运行，需要将训练集放入“SuperResolutionICCV2013\Database\Train”,将测试集放入“SuperResolutionICCV2013\Database\Test_GroundTruth”
