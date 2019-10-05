# encoding: utf-8

from OAT import *
import json
import requests
from functools import partial
from nose.tools import *

"""
pip install requests
pip install nose
"""


class check_response():
    @staticmethod
    def check_result(response, params, expectNum=None):
        # 由于搜索结果存在模糊匹配的情况，这里简单处理只校验第一个返回结果的正确性
        if expectNum is not None:
            # 期望结果数目不为None时，只判断返回结果数目
            eq_(expectNum, len(response['subjects']), '{0}!={1}'.format(expectNum, len(response['subjects'])))
        else:
            if not response['subjects']:
                # 结果为空，直接返回失败
                assert False
            else:
                # 结果不为空，校验第一个结果
                subject = response['subjects'][0]
                # 先校验搜索条件tag
                if params.get('tag'):
                    for word in params['tag'].split(','):
                        genres = subject['genres']
                        ok_(word in genres, 'Check {0} failed!'.format(word))

                # 再校验搜索条件q
                elif params.get('q'):
                    # 依次判断片名，导演或演员中是否含有搜索词，任意一个含有则返回成功
                    for word in params['q'].split(','):
                        title = [subject['title']]
                        casts = [i['name'] for i in subject['casts']]
                        directors = [i['name'] for i in subject['directors']]
                        total = title + casts + directors
                        ok_(any(word.lower() in i.lower() for i in total),
                            'Check {0} failed!'.format(word))


class test_douban(object):
    """
    豆瓣搜索接口测试demo,文档地址 https://developers.douban.com/wiki/?title=movie_v2#search
    """

    def search(self, params, expectNum=None):
        url = 'https://api.douban.com/v2/movie/search'
        r = requests.get(url, params=params)
        print ('Search Params:\n', json.dumps(params, ensure_ascii=False))
        print ('Search Response:\n', json.dumps(r.json(), ensure_ascii=False, indent=4))
        code = r.json().get('code', 0)
        if code > 0:
            assert False, 'Invoke Error.Code:\t{0}'.format(code)
        else:
            # 校验搜索结果是否与搜索词匹配
            check_response.check_result(r.json(), params, expectNum)

    def test_q(self):
        # 校验搜索条件
        qs = [u'白夜追凶', u'大话西游', u'周星驰', u'张艺谋', u'周星驰,吴孟达', u'张艺谋,巩俐', u'周星驰,西游', u'白夜追凶,潘粤明']
        tags = [u'科幻', u'喜剧', u'动作', u'犯罪', u'科幻,喜剧', u'动作,犯罪']
        starts = [0, 10, 20]
        counts = [20, 10, 5]

        # 生成原始测试数据 （有序数组）
        cases = OrderedDict([('q', qs), ('tag', tags), ('start', starts), ('count', counts)])

        # 使用正交表裁剪生成测试集
        cases = OAT().genSets(cases, mode=1, num=0)

        # 执行测试用例
        for case in cases:
            f = partial(self.search, case)
            f.description = json.dumps(case, ensure_ascii=False)
            yield (f,)


if __name__ == "__main__":
    oat = OAT()
    case1 = OrderedDict([('acc_n', [11, 12, 13, 14, 15, 16, 17, 18]),
                         ('acc_w', [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]),
                         ('gyr_n', [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]),
                         ('gyr_w', [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26])])
                         
                         #('AXC', [1, 2]),
                         #('BXC', [1, 2])
                         #('error', [1, 2])
                         

    case2 = OrderedDict([#('acc_n', [1100, 1150, 1200, 1250, 1300, 1350, 1400, 1450, 1500, 1550, 1600, 1700]),
                         ('accn01', [130, 140, 150, 160]),
                         ('accw02', [130, 140, 150, 180]),
                         ('aanw03', [110, 120, 130, 140]),
                         ('aanw04', [110, 120, 130, 140]),
                         ('aanw05', [110, 120, 130, 140]),
                         ('gyrn06', [110, 120, 130, 140]),
                         ('agnn07', [100, 110, 120, 130]), #agw_w07
                         ('agnn08', [100, 110, 120, 130]), 
                         ('agnn09', [100, 110, 120, 130]), 
                         ('agwn10', [100, 110, 120, 130]),
                         ('gyrw11', [110, 120, 130, 140]),
                         ('none12', ['1', '2', '3', '4']),
                         ('none13', ['1', '2', '3', '4']),
                         ('agwn14', [100, 110, 120, 130]),
                         ('agww15', [100, 110, 120, 130]),
                         ('none16', ['1', '2', '3', '4']),
                         ('none17', ['1', '2', '3', '4']),
                         ('agwn18', [100, 110, 120, 130]),
                         ('agww19', [100, 110, 120, 130]), 
                         ('none20', ['1', '2', '3', '4']),
                         ('none21', ['1', '2', '3', '4']),
                          ])

    case3 = OrderedDict([(u'温度', [80, 85, 90]),
                         (u'时间', [90, 120, 150]),
                         (u'用碱量', ['5%', '6%', '7%'])])

    case4 = OrderedDict([('A', ['A1', 'A2', 'A3', 'A4', 'A5', 'A6']),
                         ('B', ['B1']),
                         ('C', ['C1'])])

    # 默认mode=0，宽松模式，只裁剪重复测试集（测试用例参数值可能为None）
    print (json.dumps(oat.genSets(case2)))
#    print (json.dumps(oat.genSets(case2)))
    #print (json.dumps(oat.genSets(case3), ensure_ascii=False))
#    print (json.dumps(oat.genSets(case4)))

    # mode=1，严格模式，除裁剪重复测试集外，还裁剪含None测试集(num为允许None测试集最大数目)
    #print (json.dumps(oat.genSets(case2, mode=1, num=0)))
    #print (json.dumps(oat.genSets(case2, mode=1, num=1)))
    #print (json.dumps(oat.genSets(case2, mode=1, num=2)))
    #print (json.dumps(oat.genSets(case2, mode=1, num=3)))
    print (len(oat.genSets(case2)))
